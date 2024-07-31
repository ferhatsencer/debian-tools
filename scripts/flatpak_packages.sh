#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Function to install Flatpak if not installed
install_flatpak() {
    if ! command -v flatpak &>/dev/null; then
        echo "Flatpak is not installed. Installing Flatpak..."
        if ! sudo apt update && sudo apt install flatpak; then
            exit_with_error "Failed to install Flatpak"
        fi
    else
        echo "Flatpak is already installed."
    fi
}

# Function to install plasma-discover-backend-flatpak if not installed
install_plasma_discover_backend() {
    if ! dpkg -s plasma-discover-backend-flatpak &>/dev/null; then
        echo "plasma-discover-backend-flatpak is not installed. Installing..."
        if ! sudo apt install plasma-discover-backend-flatpak; then
            exit_with_error "Failed to install plasma-discover-backend-flatpak"
        fi
    else
        echo "plasma-discover-backend-flatpak is already installed."
    fi
}

# Check if Flathub remote repository is added
if flatpak remote-list | grep -q "flathub"; then
    echo "Flathub repository is already added."
else
    echo "Flathub repository is not added. Adding..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Function to install Flatpak applications from Flathub
install_flatpak_apps() {
    for app in "$@"; do
        echo "Installing $app from Flathub..."
        if ! flatpak install flathub "$app"; then
            echo "Failed to install $app from Flathub"
        fi
    done
}

# List of Flatpak applications to install
flatpak_apps=(
    "network.loki.Session"
    "org.kde.tokodon"
    "org.kde.marknote"
    "org.kde.plasmatube"
    "org.kde.audiotube"
    "io.github.alainm23.planify"
    "io.github.giantpinkrobots.bootqt"
)

# Install Flatpak
install_flatpak

# Install plasma-discover-backend-flatpak
install_plasma_discover_backend

# Prompt user for confirmation
read -p "Do you want to install the specified Flatpak applications? [y/N]: " install_apps
if [[ "$install_apps" != [yY] ]]; then
    echo "Skipping installation of Flatpak applications."
else
    # Install Flatpak applications
    install_flatpak_apps "${flatpak_apps[@]}"
fi

# Update Flatpak installed apps
echo "Updating Flatpak installed applications..."
if ! flatpak update -y; then
    echo "Failed to update Flatpak applications"
else
    echo "Flatpak applications updated successfully."
fi

echo "Script execution completed."
exit 0
