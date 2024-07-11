#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if WayDroid is already installed
if dpkg -s waydroid &>/dev/null; then
    echo "WayDroid is already installed."
    exit 0
fi

# Prompt user for confirmation
read -p "Do you want to install WayDroid? [y/N]: " proceed
if [[ "$proceed" != [yY] ]]; then
    echo "Installation aborted by the user."
    exit 0
fi

# Check if WayDroid repository is already added
if [ -f "/etc/apt/sources.list.d/waydroid.list" ]; then
    echo "WayDroid repository is already added."
else
    # Install prerequisites
    echo "Installing curl..."
    if ! sudo apt install curl; then
        exit_with_error "Failed to install curl"
    fi

    # Download WayDroid installer script and execute
    echo "Downloading WayDroid installer script..."
    if ! curl https://repo.waydro.id | bash; then
        exit_with_error "Failed to execute WayDroid installer script"
    fi

    if ! grep -q "^deb.*waydro.id" /etc/apt/sources.list.d/waydroid.list; then
        exit_with_error "Failed to add WayDroid repository"
    fi
fi

# Update package lists
echo "Updating package lists..."
if ! sudo apt -qq update; then
    exit_with_error "Failed to update package lists"
fi

# Install WayDroid
echo "Installing WayDroid..."
if ! sudo apt install waydroid; then
    exit_with_error "Failed to install WayDroid"
fi

echo "WayDroid installed successfully."
exit 0
