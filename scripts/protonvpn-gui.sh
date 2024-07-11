#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if the system is Debian-based
if ! grep -q "ID=debian" /etc/os-release && ! grep -q "ID_LIKE=debian" /etc/os-release; then
    exit_with_error "This script requires a Debian-based system"
fi

# Check if ProtonVPN GUI is already installed
if dpkg -s protonvpn-gui &>/dev/null; then
    echo "ProtonVPN GUI is already installed."
    exit 0
fi

# Prompt user for confirmation
read -p "Do you want to install ProtonVPN GUI? [y/N]: " proceed
if [[ "$proceed" != [yY] ]]; then
    echo "Installation aborted by the user."
    exit 0
fi

protonvpn_version="1.0.3-3"
protonvpn_checksum="de7ef83a663049b5244736d3eabaacec003eb294a4d6024a8fbe0394f22cc4e5"

# Check if ProtonVPN repository is already added
if [ -f "/etc/apt/sources.list.d/protonvpn.list" ]; then
    echo "ProtonVPN repository is already added."
else
    # Install prerequisites
    echo "Installing curl..."
    if ! sudo apt -qq install curl; then
        exit_with_error "Failed to install curl"
    fi

    # Download ProtonVPN stable release
    echo "Downloading ProtonVPN stable release..."
    if ! wget "https://repo2.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_${protonvpn_version}_all.deb"; then
        exit_with_error "Failed to download ProtonVPN stable release"
    fi

    # Install ProtonVPN stable release
    echo "Installing ProtonVPN stable release..."
    if ! sudo dpkg -i "./protonvpn-stable-release_${protonvpn_version}_all.deb" && apt update; then
        exit_with_error "Failed to install ProtonVPN stable release"
    fi

    # Verify SHA256 checksum
    echo "Verifying SHA256 checksum..."
    if ! echo "${protonvpn_checksum}  protonvpn-stable-release_${protonvpn_version}_all.deb" | sha256sum --check -; then
        exit_with_error "SHA256 checksum verification failed"
    fi
fi

# Update package lists and upgrade packages
echo "Updating package lists and upgrading packages..."
if ! sudo apt update && sudo apt upgrade; then
    exit_with_error "Failed to update package lists or upgrade packages"
fi

# Install ProtonVPN GUI
echo "Installing ProtonVPN GUI..."
if ! sudo apt install protonvpn-gui; then
    exit_with_error "Failed to install ProtonVPN GUI"
fi

echo "ProtonVPN GUI installed successfully."

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    rm -f "protonvpn-stable-release_${protonvpn_version}_all.deb"
}

trap cleanup EXIT
