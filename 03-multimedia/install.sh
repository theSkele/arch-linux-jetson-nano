#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==============================================="
echo "Installing NVIDIA L4T Multimedia & Camera Packages"
echo "==============================================="
echo

PACKAGES=(
    "nvidia-l4t-multimedia-utils"
    "nvidia-l4t-multimedia"
    "nvidia-l4t-camera"
    "nvidia-l4t-gstreamer"
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

echo "==============================================="
echo "✓ All multimedia packages installed successfully!"
echo "==============================================="
echo
