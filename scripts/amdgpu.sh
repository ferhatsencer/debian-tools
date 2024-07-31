#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if the system is running Debian
# if [ ! -f "/etc/debian_version" ]; then
#     echo "This script is designed for Debian-based systems only."
#     exit 1
# fi

# Check if -u parameter is provided
if [ $1 = "-u" ]; then
    # Uninstall AMDGPU driver
    echo "Uninstalling AMDGPU driver..."

    # Check if AMDGPU driver is installed
    if ! dpkg -l | grep -q "amdgpu-install"; then
        echo "AMDGPU driver is not installed."
        exit 0
    fi

    # Prompt user for confirmation
    read -p "Do you want to uninstall the AMDGPU driver? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Uninstallation aborted by the user."
        exit 0
    fi

    # Remove AMDGPU driver
    echo "Removing AMDGPU driver..."
    if ! sudo apt purge amdgpu-install; then
        exit_with_error "Failed to remove AMDGPU driver"
    fi

    # Remove user from render group
    if id -nG "$LOGNAME" | grep -qw "render"; then
        echo "Removing user from render group..."
        if ! sudo gpasswd -d "$LOGNAME" render; then
            exit_with_error "Failed to remove user from render group"
        fi
    else
        echo "User is not a member of the render group."
    fi

    # Remove user from video group
    if id -nG "$LOGNAME" | grep -qw "video"; then
        echo "Removing user from video group..."
        if ! sudo gpasswd -d "$LOGNAME" video; then
            exit_with_error "Failed to remove user from video group"
        fi
    else
        echo "User is not a member of the video group."
    fi

    echo "AMDGPU driver uninstalled successfully."
else
    # Install AMDGPU driver
    echo "Installing AMDGPU driver..."

    # Check if AMDGPU driver is already installed
    if dpkg -l | grep -q "amdgpu-install"; then
        echo "AMDGPU driver is already installed."
        exit 0
    fi

    # AMDGPU driver
    driver_url="https://repo.radeon.com/amdgpu-install/6.1.3/ubuntu/jammy/amdgpu-install_6.1.60103-1_all.deb"

    # Prompt user for confirmation
    read -p "Do you want to install the AMDGPU driver? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Installation aborted by the user."
        exit 0
    fi

    # Install AMDGPU driver
    echo "Downloading AMDGPU driver..."
    if ! wget "$driver_url"; then
        exit_with_error "Failed to download AMDGPU driver"
    fi

    echo "Installing AMDGPU driver..."
    if ! sudo apt install ./amdgpu-install*.deb; then
        exit_with_error "Failed to install AMDGPU driver"
    fi

    echo "Running amdgpu-install..."
    if ! sudo amdgpu-install --usecase=graphics,opencl --vulkan=pro -y --accept-eula; then
        exit_with_error "Failed to run amdgpu-install"
    fi

    # Add user to render group if not already a member
    if ! id -nG "$LOGNAME" | grep -qw "render"; then
        echo "Adding user to render group..."
        if ! sudo usermod -a -G render "$LOGNAME"; then
            exit_with_error "Failed to add user to render group"
        fi
    else
        echo "User is already a member of the render group."
    fi

    # Add user to video group if not already a member
    if ! id -nG "$LOGNAME" | grep -qw "video"; then
        echo "Adding user to video group..."
        if ! sudo usermod -a -G video "$LOGNAME"; then
            exit_with_error "Failed to add user to video group"
        fi
    else
        echo "User is already a member of the video group."
    fi

    echo "AMDGPU driver installed successfully."
fi
