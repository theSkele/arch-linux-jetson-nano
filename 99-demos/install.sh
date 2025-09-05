#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "============================================="
echo "Installing NVIDIA L4T Demo & API Packages"
echo "============================================="
echo "These packages are optional and primarily for development/testing."
echo

PACKAGES=(
    "nvidia-l4t-graphics-demos"
    "nvidia-l4t-multimedia-api"
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

echo "============================================="
echo "✓ All demo packages installed successfully!"
echo "============================================="
echo
