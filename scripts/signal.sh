#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if -u parameter is provided
if [ $1 = "-u" ]; then
    # Uninstall Signal Desktop
    echo "Uninstalling Signal Desktop..."

    # Check if Signal Desktop is installed
    if ! dpkg -l | grep -q "signal-desktop"; then
        echo "Signal Desktop is not installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to uninstall Signal Desktop? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Uninstallation aborted by the user."
        exit 0
    fi

    # Remove Signal Desktop package
    echo "Removing Signal Desktop package..."
    if ! sudo apt purge signal-desktop; then
        exit_with_error "Failed to remove Signal Desktop package"
    fi

    # Remove Signal Desktop repository
    echo "Removing Signal Desktop repository..."
    if ! sudo rm /etc/apt/sources.list.d/signal-xenial.list; then
        exit_with_error "Failed to remove Signal Desktop repository"
    fi

    # Remove Signal Desktop keyring
    echo "Removing Signal Desktop keyring..."
    if ! sudo rm /usr/share/keyrings/signal-desktop-keyring.gpg; then
        exit_with_error "Failed to remove Signal Desktop keyring"
    fi

    # Update package lists
    echo "Updating package lists..."
    if ! sudo apt update; then
        exit_with_error "Failed to update package lists"
    fi

    echo "Signal Desktop uninstalled successfully."
else
    # Install Signal Desktop
    echo "Installing Signal Desktop..."

    # Check if Signal Desktop is already installed
    if dpkg -l | grep -q "signal-desktop"; then
        echo "Signal Desktop is already installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to install Signal Desktop? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Installation aborted by the user."
        exit 0
    fi

    # Check if Signal Desktop repository is already added
    if [ -f "/etc/apt/sources.list.d/signal-xenial.list" ]; then
        echo "Signal Desktop repository is already added."
    else
        # Download Signal Desktop keyring
        echo "Downloading Signal Desktop keyring..."
        if ! wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg; then
            exit_with_error "Failed to download Signal Desktop keyring"
        fi

        # Adding Signal Desktop keyring
        echo "Adding Signal Desktop keyring..."
        if ! cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null; then
            exit_with_error "Failed to add Signal Desktop keyring"
        fi


        # Add Signal Desktop repository
        echo "Adding Signal Desktop repository..."
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list >/dev/null
        if ! grep -q "^deb.*signal-xenial" /etc/apt/sources.list.d/signal-xenial.list; then
            exit_with_error "Failed to add Signal Desktop repository"
        fi

        # Update package lists
        echo "Updating package lists..."
        if ! sudo apt -qq update; then
            exit_with_error "Failed to update package lists"
        fi
    fi

    # Install Signal Desktop
    echo "Installing Signal Desktop..."
    if ! sudo apt -qq install signal-desktop; then
        exit_with_error "Failed to install Signal Desktop"
    fi

    # Remove Signal Keyring
    echo "Remove signal keyring..."
    if ! sudo rm signal-keyring-desktop.pgp; then
        exit_with_error "Failed to remove signal keyring"
    fi

    sudo rm wget-log

    echo "Signal Desktop installed successfully."
fi
