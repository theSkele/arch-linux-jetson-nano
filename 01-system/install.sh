#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "============================================"
echo "Installing NVIDIA L4T System Component Packages"
echo "============================================"
echo

PACKAGES=(
    "nvidia-l4t-configs"
    "nvidia-l4t-oem-config"
    "nvidia-l4t-xusb-firmware"
    "nvidia-l4t-bootloader"
    "nvidia-l4t-initrd"
    "nvidia-l4t-kernel-headers"
    "nvidia-l4t-jetson-io"
    "nvidia-l4t-gputools"
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

echo "============================================"
echo "✓ All system component packages installed successfully!"
echo "============================================"
echo
