#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if -u parameter is provided
if [ $1 = "-u" ]; then
    # Uninstall Unity Hub
    echo "Uninstalling Unity Hub..."

    # Check if Unity Hub is installed
    if ! dpkg -l | grep -q "unityhub"; then
        echo "Unity Hub is not installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to uninstall Unity Hub? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Uninstallation aborted by the user."
        exit 0
    fi

    # Remove Unity Hub package
    echo "Removing Unity Hub package..."
    if ! sudo apt-get purge unityhub; then
        exit_with_error "Failed to remove Unity Hub package"
    fi

    # Remove Unity Hub repository
    echo "Removing Unity Hub repository..."
    if ! sudo rm /etc/apt/sources.list.d/unityhub.list; then
        exit_with_error "Failed to remove Unity Hub repository"
    fi

    # Remove Unity Hub public signing key
    echo "Removing Unity Hub public signing key..."
    if ! sudo rm /usr/share/keyrings/Unity_Technologies_ApS.gpg; then
        exit_with_error "Failed to remove Unity Hub public signing key"
    fi

    # Update package cache
    echo "Updating package cache..."
    if ! sudo apt update; then
        exit_with_error "Failed to update package cache"
    fi

    echo "Unity Hub uninstalled successfully."
else
    # Install Unity Hub
    echo "Installing Unity Hub..."

    # Check if Unity Hub is already installed
    if dpkg -l | grep -q "unityhub"; then
        echo "Unity Hub is already installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to install Unity Hub? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Installation aborted by the user."
        exit 0
    fi

    # Add Unity Hub public signing key
    echo "Adding Unity Hub public signing key..."
    if ! wget -qO - https://hub.unity3d.com/linux/keys/public | gpg --dearmor | sudo tee /usr/share/keyrings/Unity_Technologies_ApS.gpg > /dev/null; then
        exit_with_error "Failed to add Unity Hub public signing key"
    fi

    # Add Unity Hub repository
    echo "Adding Unity Hub repository..."
    if ! sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/Unity_Technologies_ApS.gpg] https://hub.unity3d.com/linux/repos/deb stable main" > /etc/apt/sources.list.d/unityhub.list'; then
        exit_with_error "Failed to add Unity Hub repository"
    fi

    # Update package cache
    echo "Updating package cache..."
    if ! sudo apt update; then
        exit_with_error "Failed to update package cache"
    fi

    # Install Unity Hub
    echo "Installing Unity Hub..."
    if ! sudo apt-get install unityhub; then
        exit_with_error "Failed to install Unity Hub"
    fi

    echo "Unity Hub installed successfully."
fi
