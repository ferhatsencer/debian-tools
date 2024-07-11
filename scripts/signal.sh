#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if Signal Desktop is already installed
if dpkg -s signal-desktop &>/dev/null; then
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
    # Install prerequisites
    echo "Installing wget..."
    if ! sudo apt -qq install wget; then
        exit_with_error "Failed to install wget"
    fi

    # Download Signal Desktop keyring
    echo "Downloading Signal Desktop keyring..."
    if ! wget -qO- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > /usr/share/keyrings/signal-desktop-keyring.gpg; then
        exit_with_error "Failed to download Signal Desktop keyring"
    fi

    # Add Signal Desktop repository
    echo "Adding Signal Desktop repository..."
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | tee /etc/apt/sources.list.d/signal-xenial.list >/dev/null
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

echo "Signal Desktop installed successfully."
exit 0
