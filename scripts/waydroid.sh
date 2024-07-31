#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if -u parameter is provided
if [ $1 = "-u" ]; then
    # Uninstall WayDroid
    echo "Uninstalling WayDroid..."

    # Check if WayDroid is installed
    if ! dpkg -l | grep -q "waydroid"; then
        echo "WayDroid is not installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to uninstall WayDroid? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Uninstallation aborted by the user."
        exit 0
    fi

    # Remove WayDroid package
    echo "Removing WayDroid package..."
    if ! sudo apt purge waydroid; then
        exit_with_error "Failed to remove WayDroid package"
    fi

    # Remove WayDroid repository
    echo "Removing WayDroid repository..."
    if ! sudo rm /etc/apt/sources.list.d/waydroid.list; then
        exit_with_error "Failed to remove WayDroid repository"
    fi

    # Update package lists
    echo "Updating package lists..."
    if ! sudo apt update; then
        exit_with_error "Failed to update package lists"
    fi

    # Remove WayDroid data
    echo "Removing WayDroid data..."
    echo "WARNING: You will need to run the following command after rebooting to complete the uninstallation:"
    echo "sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*waydroid* ~/.local/share/waydroid"
    echo "Please make a note of this command and run it after rebooting."

    echo "WayDroid uninstalled successfully. Please reboot your system and run the above command to complete the uninstallation."
else
    # Install WayDroid
    echo "Installing WayDroid..."

    # Check if WayDroid is already installed
    if dpkg -l | grep -q "waydroid"; then
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
fi
