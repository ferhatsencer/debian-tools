#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if Eddie UI is already installed
if dpkg -s eddie-ui &>/dev/null; then
    echo "Eddie UI is already installed."
    exit 0
fi

# Prompt user for confirmation
read -p "Do you want to install Eddie UI? [y/N]: " proceed
if [[ "$proceed" != [yY] ]]; then
    echo "Installation aborted by the user."
    exit 0
fi

# Check if Eddie UI repository is already added
if [ -f "/etc/apt/sources.list.d/eddie.website.list" ]; then
    echo "Eddie UI repository is already added."
else
    # Install prerequisites
    echo "Installing curl..."
    if ! sudo apt -qq install curl; then
        exit_with_error "Failed to install curl"
    fi

    # Download Eddie UI keyring
    echo "Downloading Eddie UI keyring..."
    if ! curl -fsSL https://eddie.website/repository/keys/eddie_maintainer_gpg.key | sudo tee /usr/share/keyrings/eddie.website-keyring.asc > /dev/null; then
        exit_with_error "Failed to download Eddie UI keyring"
    fi

    # Add Eddie UI repository
    echo "Adding Eddie UI repository..."
    echo "deb [signed-by=/usr/share/keyrings/eddie.website-keyring.asc] http://eddie.website/repository/apt stable main" | sudo tee /etc/apt/sources.list.d/eddie.website.list >/dev/null
    if ! grep -q "^deb.*eddie.website" /etc/apt/sources.list.d/eddie.website.list; then
        exit_with_error "Failed to add Eddie UI repository"
    fi

    # Update package lists
    echo "Updating package lists..."
    if ! sudo apt -qq update; then
        exit_with_error "Failed to update package lists"
    fi
fi

# Install Eddie UI
echo "Installing Eddie UI..."
if ! sudo apt -qq install eddie-ui; then
    exit_with_error "Failed to install Eddie UI"
fi

echo "Eddie UI installed successfully."
