#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if -u parameter is provided
if [ $1 = "-u" ]; then
    # Uninstall IVPN
    echo "Uninstalling IVPN..."

    # Check if IVPN is installed
    if ! dpkg -l | grep -q "ivpn"; then
        echo "IVPN is not installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to uninstall IVPN? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Uninstallation aborted by the user."
        exit 0
    fi

    # Remove IVPN package
    echo "Removing IVPN package..."
    if ! sudo apt purge ivpn ivpn-ui; then
        exit_with_error "Failed to remove IVPN package"
    fi

    # Remove IVPN repository
    echo "Removing IVPN repository..."
    if ! sudo rm /etc/apt/sources.list.d/ivpn.list; then
        exit_with_error "Failed to remove IVPN repository"
    fi

    # Remove IVPN's GPG key
    echo "Removing IVPN's GPG key..."
    if ! sudo rm /usr/share/keyrings/ivpn-archive-keyring.gpg; then
        exit_with_error "Failed to remove IVPN's GPG key"
    fi

    # Remove IVPN's folder in opt
    echo "Removing IVPN's folder in opt..."
    if ! sudo rm -r /opt/ivpn/; then
        exit_with_error "Failed to Removing IVPN's folder in opt"
    fi

    # Update APT repo info
    echo "Updating APT repo info..."
    if ! sudo apt update; then
        exit_with_error "Failed to update APT repo info"
    fi

    echo "IVPN uninstalled successfully."
else
    # Install IVPN
    echo "Installing IVPN..."

    # Check if IVPN is already installed
    if dpkg -l | grep -q "ivpn"; then
        echo "IVPN is already installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to install IVPN? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Installation aborted by the user."
        exit 0
    fi

    # Check if IVPN repository is already added
    if [ -f "/etc/apt/sources.list.d/ivpn.list" ]; then
        echo "IVPN repository is already added."
    else
        # Add IVPN's GPG key
        echo "Adding IVPN's GPG key..."
        if ! curl -fsSL https://repo.ivpn.net/stable/ubuntu/generic.gpg | gpg --dearmor > ~/ivpn-archive-keyring.gpg; then
            exit_with_error "Failed to add IVPN's GPG key"
        fi

        # Move GPG key to /usr/share/keyrings
        echo "Moving GPG key to /usr/share/keyrings..."
        if ! sudo mv ~/ivpn-archive-keyring.gpg /usr/share/keyrings/ivpn-archive-keyring.gpg; then
            exit_with_error "Failed to move GPG key"
        fi

        # Set Appropriate Permissions for GPG key
        echo "Setting permissions for GPG key..."
        if ! sudo chown root:root /usr/share/keyrings/ivpn-archive-keyring.gpg || ! sudo chmod 644 /usr/share/keyrings/ivpn-archive-keyring.gpg; then
            exit_with_error "Failed to set permissions for GPG key"
        fi

        # Add the IVPN repository
        echo "Adding IVPN repository..."
        if ! curl -fsSL https://repo.ivpn.net/stable/ubuntu/generic.list | sudo tee /etc/apt/sources.list.d/ivpn.list; then
            exit_with_error "Failed to add IVPN repository"
        fi

        # Set Appropriate Permissions for Repository
        echo "Setting permissions for repository..."
        if ! sudo chown root:root /etc/apt/sources.list.d/ivpn.list || ! sudo chmod 644 /etc/apt/sources.list.d/ivpn.list; then
            exit_with_error "Failed to set permissions for repository"
        fi

        # Update APT repo info
        echo "Updating APT repo info..."
        if ! sudo apt update; then
            exit_with_error "Failed to update APT repo info"
        fi
    fi

    # Prompt user to choose between CLI and UI installation
    read -p "Do you want to install IVPN with UI (y) or only CLI (n)? [y/N]: " ui_install
    if [[ "$ui_install" == [yY] ]]; then
        # Install IVPN software (CLI and UI)
        echo "Installing IVPN with UI..."
        if ! sudo apt install ivpn-ui; then
            exit_with_error "Failed to install IVPN with UI"
        fi
    else
        # Install only IVPN CLI
        echo "Installing IVPN CLI..."
        if ! sudo apt install ivpn; then
            exit_with_error "Failed to install IVPN CLI"
        fi
    fi

    echo "IVPN installed successfully."
fi
