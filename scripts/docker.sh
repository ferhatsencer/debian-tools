#!/usr/bin/env bash

# Usage:
#   ./docker-install.sh         Install Docker
#   ./docker-install.sh -u      Uninstall Docker

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if -u parameter is provided
if [ $1 = "-u" ]; then
    # Uninstall Docker
    echo "Uninstalling Docker..."

    # Check if Docker is installed
    if ! dpkg -l | grep -q "docker-ce"; then
        echo "Docker is not installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to uninstall Docker? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Uninstallation aborted by the user."
        exit 0
    fi

    # Stop Docker service
    echo "Stopping Docker service..."
    if ! sudo systemctl stop docker; then
        exit_with_error "Failed to stop Docker service"
    fi

    # Remove Docker packages
    echo "Removing Docker packages..."
    if ! sudo apt purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && sudo apt purge docker-ce*; then
        exit_with_error "Failed to remove Docker packages"
    fi

    # Remove Docker repository
    echo "Removing Docker repository..."
    if ! sudo rm /etc/apt/sources.list.d/docker.list; then
        exit_with_error "Failed to remove Docker repository"
    fi

    # Remove Docker's GPG key
    echo "Removing Docker's GPG key..."
    if ! sudo rm /etc/apt/keyrings/docker.asc; then
        exit_with_error "Failed to remove Docker's GPG key"
    fi

    # Update APT repo info
    echo "Updating APT repo info..."
    if ! sudo apt update; then
        exit_with_error "Failed to update APT repo info"
    fi

    # Remove Docker group
    echo "Removing Docker group..."
    if ! sudo groupdel docker; then
        exit_with_error "Failed to remove Docker group"
    fi

    echo "Docker uninstalled successfully."
else
    # Install Docker
    echo "Installing Docker..."

    # Check if Docker is installed
    if dpkg -l | grep -q "docker-ce"; then
        echo "Docker is already installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to install Docker? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Installation aborted by the user."
        exit 0
    fi

    # Check if Docker repository is already added
    if [ -f "/etc/apt/sources.list.d/docker.list" ]; then
        echo "Docker repository is already added."
    else
        # Update APT repo info
        echo "Updating APT repo info..."
        if ! sudo apt update; then
            exit_with_error "Failed to update APT repo info"
        fi

        # Install prerequisites
        echo "Installing prerequisites..."
        if ! sudo apt install ca-certificates curl; then
            exit_with_error "Failed to install prerequisites"
        fi

        # Create directory for Docker's GPG key
        echo "Creating directory for Docker's GPG key..."
        if ! sudo install -m 0755 -d /etc/apt/keyrings; then
            exit_with_error "Failed to create directory for Docker's GPG key"
        fi

        # Add Docker's official GPG key
        echo "Adding Docker's official GPG key..."
        if ! sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc; then
            exit_with_error "Failed to add Docker's official GPG key"
        fi

        # Set permissions for Docker's GPG key
        echo "Setting permissions for Docker's GPG key..."
        if ! sudo chmod a+r /etc/apt/keyrings/docker.asc; then
            exit_with_error "Failed to set permissions for Docker's GPG key"
        fi

        # Add Docker repository
        echo "Adding Docker repository..."
        if ! echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; then
            exit_with_error "Failed to add Docker repository"
        fi

        # Update APT repo info
        echo "Updating APT repo info..."
        if ! sudo apt update; then
            exit_with_error "Failed to update APT repo info"
        fi
    fi

    # Install Docker
    echo "Installing Docker..."
    if ! sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
        exit_with_error "Failed to install Docker"
    fi

    # Create Docker group
    echo "Creating Docker group..."
    if ! sudo groupadd docker; then
        exit_with_error "Failed to create Docker group"
    fi

    # Add user to Docker group
    echo "Adding user to Docker group..."
    if ! sudo usermod -aG docker $USER; then
        exit_with_error "Failed to add user to Docker group"
    fi

    echo "Docker installed successfully. Please log out and log back in to use Docker."
fi
