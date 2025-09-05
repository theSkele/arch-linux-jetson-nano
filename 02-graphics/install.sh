#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==========================================="
echo "Installing NVIDIA L4T Graphics Packages"
echo "==========================================="
echo

PACKAGES=(
    "nvidia-l4t-libvulkan"
    "nvidia-l4t-wayland"
    "nvidia-l4t-3d-core"
    "nvidia-l4t-x11"
    "nvidia-l4t-cuda"
)

for package in "${PACKAGES[@]}"; do
    echo "----------------------------------------"
    echo "Building and installing: $package"
    echo "----------------------------------------"
    
    if [[ ! -d "$package" ]]; then
        echo "ERROR: Package directory $package not found!"
        exit 1
    fi
    
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

echo "==========================================="
echo "✓ All graphics packages installed successfully!"
echo "==========================================="
echo
