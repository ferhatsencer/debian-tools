#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if -u parameter is provided
if [ $1 = "-u" ]; then
    # Uninstall Eddie
    echo "Uninstalling Eddie..."

    # Check if Eddie is installed
    if ! dpkg -l | grep -q "eddie-ui"; then
        echo "Eddie is not installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to uninstall Eddie? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Uninstallation aborted by the user."
        exit 0
    fi

    # Remove Eddie package
    echo "Removing Eddie package..."
    if ! sudo apt purge eddie-ui; then
        exit_with_error "Failed to remove Eddie package"
    fi

    # Remove Eddie repository
    echo "Removing Eddie repository..."
    if ! sudo rm /etc/apt/sources.list.d/eddie.website.list; then
        exit_with_error "Failed to remove Eddie repository"
    fi

    # Remove Eddie maintainer key
    echo "Removing Eddie maintainer key..."
    if ! sudo rm /usr/share/keyrings/eddie.website-keyring.asc; then
        exit_with_error "Failed to remove Eddie maintainer key"
    fi

    # Update APT repo info
    echo "Updating APT repo info..."
    if ! sudo apt update; then
        exit_with_error "Failed to update APT repo info"
    fi

    echo "Eddie uninstalled successfully."
else
    # Install Eddie
    echo "Installing Eddie..."

    # Check if Eddie is already installed
    if dpkg -l | grep -q "eddie-ui"; then
        echo "Eddie is already installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to install Eddie? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Installation aborted by the user."
        exit 0
    fi

    # Check if Eddie repository is already added
    if [ -f "/etc/apt/sources.list.d/eddie.website.list" ]; then
        echo "Eddie repository is already added."
    else
        # Import Eddie maintainer key
        echo "Importing Eddie maintainer key..."
        if ! curl -fsSL https://eddie.website/repository/keys/eddie_maintainer_gpg.key | sudo tee /usr/share/keyrings/eddie.website-keyring.asc > /dev/null; then
            exit_with_error "Failed to import Eddie maintainer key"
        fi

        # Add Eddie repository
        echo "Adding Eddie repository..."
        if ! echo "deb [signed-by=/usr/share/keyrings/eddie.website-keyring.asc] http://eddie.website/repository/apt stable main" | sudo tee /etc/apt/sources.list.d/eddie.website.list; then
            exit_with_error "Failed to add Eddie repository"
        fi

        # Update APT repo info
        echo "Updating APT repo info..."
        if ! sudo apt update; then
            exit_with_error "Failed to update APT repo info"
        fi
    fi

    # Install Eddie
    echo "Installing Eddie..."
    if ! sudo apt install eddie-ui; then
        exit_with_error "Failed to install Eddie"
    fi

    echo "Eddie installed successfully."
fi
