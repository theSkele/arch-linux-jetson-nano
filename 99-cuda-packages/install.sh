#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Installing CUDA Development Packages"
echo "=========================================="
echo "These packages provide CUDA development tools and libraries."
echo

available_packages=()
for dir in */; do
    if [[ -d "$dir" && "$dir" != "README.md" ]]; then
        package_name="${dir%/}"
        if [[ -f "$dir/PKGBUILD" ]]; then
            available_packages+=("$package_name")
        fi
    fi
done

if [[ ${#available_packages[@]} -eq 0 ]]; then
    echo "No CUDA development packages found in this directory."
    echo "Expected packages: cuda-command-line-tools-10-2, cuda-cudart-10-2, etc."
    exit 0
fi

echo "Found CUDA packages:"
for package in "${available_packages[@]}"; do
    echo "  - $package"
done
echo

for package in "${available_packages[@]}"; do
    echo "----------------------------------------"
    echo "Building and installing: $package"
    echo "----------------------------------------"
    
    cd "$package"
    
    echo "Building and installing $package..."
    if ! makepkg -sri --noconfirm; then
        echo "ERROR: Failed to build and install $package"
        exit 1
    fi
    
    cd ..
    echo "✓ Successfully installed $package"
    echo
done

echo "=========================================="
echo "✓ CUDA development packages installed successfully!"
echo "=========================================="
echo
