#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if LibreWolf browser is already installed
if dpkg -s librewolf &>/dev/null; then
    echo "LibreWolf browser is already installed."
    exit 0
fi

# Prompt user for confirmation
read -p "Do you want to install LibreWolf browser? [y/N]: " proceed
if [[ "$proceed" != [yY] ]]; then
    echo "Installation aborted by the user."
    exit 0
fi

# Install prerequisites if not already installed
echo "Installing required packages..."
if ! sudo apt update && sudo apt install wget gnupg lsb-release apt-transport-https ca-certificates; then
    exit_with_error "Failed to install required packages"
fi

# Determine distribution code name
distro=$(if echo " una bookworm vanessa focal jammy bullseye vera uma " | grep -q " $(lsb_release -sc) "; then lsb_release -sc; else echo focal; fi)

# Check if LibreWolf repository is already added
if [ -f "/etc/apt/sources.list.d/librewolf.sources" ]; then
    echo "LibreWolf repository is already added."
else
    # Download LibreWolf keyring
    echo "Downloading LibreWolf keyring..."
    if ! wget -O- https://deb.librewolf.net/keyring.gpg | gpg --dearmor -o /usr/share/keyrings/librewolf.gpg; then
        exit_with_error "Failed to download LibreWolf keyring"
    fi

    # Add LibreWolf repository
    echo "Adding LibreWolf repository..."
    if ! sudo tee /etc/apt/sources.list.d/librewolf.sources << EOF > /dev/null
Types: deb
URIs: https://deb.librewolf.net
Suites: $distro
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/librewolf.gpg
EOF
    then
        exit_with_error "Failed to add LibreWolf repository"
    fi

    if ! grep -q "^Types: deb$" /etc/apt/sources.list.d/librewolf.sources; then
        exit_with_error "Failed to add LibreWolf repository"
    fi
fi

# Update package lists
echo "Updating package lists..."
if ! sudo apt update; then
    exit_with_error "Failed to update package lists"
fi

# Install LibreWolf browser
echo "Installing LibreWolf browser..."
if ! sudo apt install -y librewolf; then
    exit_with_error "Failed to install LibreWolf browser"
fi

echo "LibreWolf browser installed successfully."
exit 0
