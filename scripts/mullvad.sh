#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if Mullvad VPN is already installed
if dpkg -s mullvad-vpn &>/dev/null; then
    echo "Mullvad VPN is already installed."
    exit 0
fi

# Prompt user for confirmation
read -p "Do you want to install Mullvad VPN? [y/N]: " proceed
if [[ "$proceed" != [yY] ]]; then
    echo "Installation aborted by the user."
    exit 0
fi

# Check if Mullvad repository is already added
if [ -f "/etc/apt/sources.list.d/mullvad.list" ]; then
    echo "Mullvad repository is already added."
else
    # Install prerequisites
    echo "Installing curl..."
    if ! sudo apt install curl; then
        exit_with_error "Failed to install curl"
    fi

    # Download Mullvad keyring
    echo "Downloading Mullvad keyring..."
    if ! sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc; then
        exit_with_error "Failed to download Mullvad keyring"
    fi

    # Add Mullvad repository
    echo "Adding Mullvad repository..."
    echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/mullvad.list >/dev/null
    if ! grep -q "^deb.*mullvad" /etc/apt/sources.list.d/mullvad.list; then
        exit_with_error "Failed to add Mullvad repository"
    fi

    # Update package lists
    echo "Updating package lists..."
    if ! sudo apt -qq update; then
        exit_with_error "Failed to update package lists"
    fi
fi

# Install Mullvad VPN
echo "Installing Mullvad VPN..."
if ! sudo apt -qq -y install mullvad-vpn; then
    exit_with_error "Failed to install Mullvad VPN"
fi

if ! sudo apt -qq -y install mullvad-browser; then
    exit_with_error "Failed to install Mullvad VPN"
fi

echo "Mullvad VPN installed successfully."
exit 0
