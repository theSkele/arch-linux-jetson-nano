#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Function to install a package
install_package() {
    local pkg_dir="$1"
    if [ -d "$pkg_dir" ]; then
        print_status "Installing package: $pkg_dir"
        cd "$pkg_dir" || return 1
        makepkg -sri
        local exit_code=$?
        cd ..
        if [ $exit_code -ne 0 ]; then
            print_error "Failed to install $pkg_dir"
            return 1
        fi
        print_status "Successfully installed $pkg_dir"
        return 0
    else
        print_warning "Directory $pkg_dir not found, skipping..."
        return 0
    fi
}

# Required packages in order
REQUIRED_PACKAGES=(
    "nvidia-l4t-core"
    "nvidia-l4t-tools"
    "nvidia-l4t-init"
    "nvidia-l4t-firmware"
    "nvidia-l4t-kernel"
)

print_header "Installing Required NVIDIA L4T Packages"

# Install required packages in order
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! install_package "${pkg}/"; then
        read -p "Package $pkg failed to install. Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Installation aborted."
            exit 1
        fi
    fi
done

print_header "Scanning for Additional Packages"

# Find all remaining nvidia-*/, cuda-*/, and libndi/ directories
ADDITIONAL_PACKAGES=()

# Add remaining nvidia-* packages (excluding already installed ones)
for dir in nvidia-*/; do
    [ -d "$dir" ] || continue
    pkg_name=$(basename "$dir")
    if [[ ! " ${REQUIRED_PACKAGES[@]} " =~ " ${pkg_name} " ]]; then
        ADDITIONAL_PACKAGES+=("$dir")
    fi
done

# Add cuda-* packages
for dir in cuda-*/; do
    [ -d "$dir" ] || continue
    ADDITIONAL_PACKAGES+=("$dir")
done

# Add libndi/ if it exists
if [ -d "libndi/" ]; then
    ADDITIONAL_PACKAGES+=("libndi/")
fi

# Check if there are additional packages
if [ ${#ADDITIONAL_PACKAGES[@]} -eq 0 ]; then
    print_status "No additional packages found."
    exit 0
fi

print_header "Additional Packages Found"

# Display numbered list of additional packages
echo "The following additional packages were found:"
echo
for i in "${!ADDITIONAL_PACKAGES[@]}"; do
    printf "%2d. %s\n" $((i+1)) "${ADDITIONAL_PACKAGES[$i]%/}"
done

echo
print_status "By default, ALL packages will be installed."
echo "To exclude packages, enter their numbers separated by spaces (e.g., '1 3 5')"
echo "Press Enter to install all packages, or 'q' to quit:"

# Read user input
read -r user_input

# Handle quit
if [[ "$user_input" =~ ^[Qq]$ ]]; then
    print_status "Installation cancelled by user."
    exit 0
fi

# Parse exclusions
EXCLUDED_INDICES=()
if [ -n "$user_input" ]; then
    read -ra EXCLUDED_NUMBERS <<< "$user_input"
    for num in "${EXCLUDED_NUMBERS[@]}"; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#ADDITIONAL_PACKAGES[@]} ]; then
            EXCLUDED_INDICES+=($((num-1)))
        else
            print_warning "Invalid number: $num (ignoring)"
        fi
    done
fi

# Create list of packages to install
PACKAGES_TO_INSTALL=()
for i in "${!ADDITIONAL_PACKAGES[@]}"; do
    excluded=false
    for excluded_idx in "${EXCLUDED_INDICES[@]}"; do
        if [ "$i" -eq "$excluded_idx" ]; then
            excluded=true
            break
        fi
    done
    
    if [ "$excluded" = false ]; then
        PACKAGES_TO_INSTALL+=("${ADDITIONAL_PACKAGES[$i]}")
    fi
done

# Show what will be installed/excluded
if [ ${#EXCLUDED_INDICES[@]} -gt 0 ]; then
    echo
    print_warning "Excluded packages:"
    for excluded_idx in "${EXCLUDED_INDICES[@]}"; do
        echo "  - ${ADDITIONAL_PACKAGES[$excluded_idx]%/}"
    done
fi

if [ ${#PACKAGES_TO_INSTALL[@]} -eq 0 ]; then
    print_status "No packages selected for installation."
    exit 0
fi

echo
print_status "Packages to be installed:"
for pkg in "${PACKAGES_TO_INSTALL[@]}"; do
    echo "  - ${pkg%/}"
done

echo
read -p "Proceed with installation? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    print_status "Installation cancelled by user."
    exit 0
fi

print_header "Installing Additional Packages"

# Install selected packages
failed_packages=()
for pkg_dir in "${PACKAGES_TO_INSTALL[@]}"; do
    if ! install_package "$pkg_dir"; then
        failed_packages+=("$pkg_dir")
        read -p "Continue with remaining packages? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            break
        fi
    fi
done

# Final summary
print_header "Installation Summary"
if [ ${#failed_packages[@]} -eq 0 ]; then
    print_status "All packages installed successfully!"
else
    print_warning "The following packages failed to install:"
    for failed_pkg in "${failed_packages[@]}"; do
        echo "  - ${failed_pkg%/}"
    done
fi

print_status "Installation script completed."