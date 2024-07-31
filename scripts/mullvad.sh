#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if -u parameter is provided
if [ $1 = "-u" ]; then
    # Uninstall Mullvad VPN
    echo "Uninstalling Mullvad VPN..."

    # Check if Mullvad VPN is installed
    if ! dpkg -l | grep -q "mullvad-vpn" && ! dpkg -l | grep -q "mullvad-browser"; then
        echo "Mullvad VPN is not installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to uninstall Mullvad VPN? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Uninstallation aborted by the user."
        exit 0
    fi

    # Remove Mullvad VPN package
    echo "Removing Mullvad VPN package..."
    if ! sudo apt purge mullvad-vpn mullvad-browser; then
        exit_with_error "Failed to remove Mullvad VPN package"
    fi

    # Remove Mullvad repository
    echo "Removing Mullvad repository..."
    if ! sudo rm /etc/apt/sources.list.d/mullvad.list; then
        exit_with_error "Failed to remove Mullvad repository"
    fi

    # Remove Mullvad signing key
    echo "Removing Mullvad signing key..."
    if ! sudo rm /usr/share/keyrings/mullvad-keyring.asc; then
        exit_with_error "Failed to remove Mullvad signing key"
    fi

    # Remove Mullvad folder in opt
    echo "Removing Mullvad folder in opt..."
    if ! sudo rm -r /opt/Mullvad\ VPN/; then
        exit_with_error "Failed to remove Mullvad folder in opt"
    fi

    # Update package lists
    echo "Updating package lists..."
    if ! sudo apt update; then
        exit_with_error "Failed to update package lists"
    fi

    echo "Mullvad VPN uninstalled successfully."
else
    # Install Mullvad VPN
    echo "Installing Mullvad VPN..."

    # Check if Mullvad VPN is already installed
    if dpkg -l | grep -q "mullvad-vpn" || dpkg -l | grep -q "mullvad-browser"; then
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
        if ! sudo apt install -y curl; then
            exit_with_error "Failed to install curl"
        fi

        # Download Mullvad signing key
        echo "Downloading Mullvad signing key..."
        if ! curl -fsSL https://repository.mullvad.net/deb/mullvad-keyring.asc | sudo tee /usr/share/keyrings/mullvad-keyring.asc > /dev/null; then
            exit_with_error "Failed to download Mullvad signing key"
        fi

        # Add Mullvad repository
        echo "Adding Mullvad repository..."
        echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$(dpkg --print-architecture)] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list >/dev/null
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

    # Install Mullvad Browser
    echo "Installing Mullvad Browser..."
    if ! sudo apt -qq -y install mullvad-browser; then
        exit_with_error "Failed to install Mullvad VPN"
    fi

    echo "Mullvad VPN & Browser installed successfully."
fi
