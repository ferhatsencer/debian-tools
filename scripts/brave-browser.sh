#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if -u parameter is provided
if [ $1 = "-u" ]; then
    # Uninstall Brave browser
    echo "Uninstalling Brave browser..."

    # Check if Brave browser is installed
    if ! dpkg -l | grep -q "brave-browser"; then
        echo "Brave browser is not installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to uninstall Brave browser? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Uninstallation aborted by the user."
        exit 0
    fi

    # Remove Brave browser package
    echo "Removing Brave browser package..."
    if ! sudo apt purge brave-browser; then
        exit_with_error "Failed to remove Brave browser package"
    fi

    # Remove Brave browser repository
    echo "Removing Brave browser repository..."
    if ! sudo rm /etc/apt/sources.list.d/brave-browser-release.list; then
        exit_with_error "Failed to remove Brave browser repository"
    fi

    # Remove Brave browser keyring
    echo "Removing Brave browser keyring..."
    if !( sudo rm /usr/share/keyrings/brave-browser-archive-keyring.gpg & sudo rm /usr/share/keyrings/brave-browser-beta-archive-keyring.gpg & sudo rm /usr/share/keyrings/brave-browser-nightly-archive-keyring.gpg); then
        exit_with_error "Failed to remove Brave browser keyring"
    fi

    # Update package lists
    echo "Updating package lists..."
    if ! sudo apt -qq update; then
        exit_with_error "Failed to update package lists"
    fi

    echo "Brave browser uninstalled successfully."
else
    # Install Brave browser
    echo "Installing Brave browser..."

    # Check if Brave browser is already installed
    if dpkg -l | grep -q "brave-browser"; then
        echo "Brave browser is already installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to install Brave browser? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Installation aborted by the user."
        exit 0
    fi

    # Check if Brave browser repository is already added
    if [ -f "/etc/apt/sources.list.d/brave-browser-release.list" ]; then
        echo "Brave browser repository is already added."
    else
        # Install prerequisites
        echo "Installing curl..."
        if ! sudo apt install curl; then
            exit_with_error "Failed to install curl"
        fi

        # Download Brave browser keyring
        echo "Downloading Brave browser keyring..."
        if ! sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg; then
            exit_with_error "Failed to download Brave browser keyring"
        fi

        # Add Brave browser repository
        echo "Adding Brave browser repository..."
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null
        if ! grep -q "^deb.*brave-browser" /etc/apt/sources.list.d/brave-browser-release.list; then
            exit_with_error "Failed to add Brave browser repository"
        fi

        # Update package lists
        echo "Updating package lists..."
        if ! sudo apt -qq update; then
            exit_with_error "Failed to update package lists"
        fi
    fi

    # Install Brave browser
    echo "Installing Brave browser..."
    if ! sudo apt install brave-browser; then
        exit_with_error "Failed to install Brave browser"
    fi

    echo "Brave browser installed successfully."
fi
