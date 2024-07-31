#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if -u parameter is provided
if [ $1 = "-u" ]; then
    # Uninstall QEMU, KVM, and related tools
    echo "Uninstalling QEMU, KVM, and related tools..."

    # Prompt user for confirmation
    read -p "Do you want to uninstall QEMU, KVM, and related tools? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Uninstallation aborted by the user."
        exit 0
    fi

    # Remove QEMU, KVM, and related tools
    if ! sudo apt purge qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager; then
        exit_with_error "Failed to remove QEMU, KVM, and related tools"
    fi

    # Disable and stop the libvirt service
    if ! sudo systemctl disable libvirtd; then
        exit_with_error "Failed to disable libvirtd service"
    fi
    if ! sudo systemctl stop libvirtd; then
        exit_with_error "Failed to stop libvirtd service"
    fi

    # Prompt for the username
    read -p 'Enter the username: ' username

    # Remove user from libvirt group
    echo "Checking if user $username is already in the libvirt group..."
    if groups $username | grep -qw libvirt; then
        echo "Removing user $username from libvirt group..."
        if ! sudo gpasswd -d $username libvirt; then
            exit_with_error "Failed to remove user $username from libvirt group"
        fi
        echo "User $username removed from libvirt group successfully."
    else
        echo "User $username is not a member of libvirt."
    fi

    # Remove user from kvm group
    echo "Checking if user $username is already in the kvm group..."
    if groups $username | grep -qw kvm; then
        echo "Removing user $username from kvm group..."
        if ! sudo gpasswd -d $username kvm; then
            exit_with_error "Failed to remove user $username from kvm group"
        fi
        echo "User $username removed from kvm group successfully."
    else
        echo "User $username is not a member of kvm."
    fi

    echo "Uninstallation complete."
else
    # Install QEMU, KVM, and related tools
    echo "Installing QEMU, KVM, and related tools..."

    # Prompt user for confirmation
    read -p "Do you want to install QEMU, KVM, and related tools? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Installation aborted by the user."
        exit 0
    fi

    # Update package list and upgrade packages
    if ! sudo apt update && sudo apt upgrade; then
        exit_with_error "Failed to update package list or upgrade packages"
    fi

    # Install QEMU, KVM, and related tools
    if ! sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager; then
        exit_with_error "Failed to install QEMU, KVM, and related tools"
    fi

    # Enable and start the libvirt service
    if ! sudo systemctl enable libvirtd; then
        exit_with_error "Failed to enable libvirtd service"
    fi
    if ! sudo systemctl start libvirtd; then
        exit_with_error "Failed to start libvirtd service"
    fi

    # Prompt for the username
    read -p 'Enter the username: ' username

    echo ""
    # Add user to libvirt group using $USER
    echo "Checking if user $username is already in the libvirt group..."
    if groups $username | grep -qw libvirt; then
        echo "User $username is already a member of libvirt."
    else
        echo "Adding user $username to libvirt group..."
        if ! sudo usermod -aG libvirt $username; then
            exit_with_error "Failed to add user $username to libvirt group"
        fi
        echo "User $username added to libvirt group successfully."
    fi

    echo ""
    # Add user to kvm group using $USER
    echo "Checking if user $username is already in the kvm group..."
    if groups $username | grep -qw kvm; then
        echo "User $username is already a member of kvm"
    else
        echo "Adding user $username to kvm group..."
        if ! sudo usermod -aG kvm $username; then
            exit_with_error "Failed to add user $username to kvm group"
        fi
        echo "User $username added to kvm group successfully."
    fi

    # Check if CPU supports virtualization
    if grep -E -c '(vmx|svm)' /proc/cpuinfo > /dev/null; then
        echo "Virtualization is supported on this machine."
    else
        echo "Virtualization is not supported on this machine."
        exit 1
    fi

    # Display a message to log out and log back in
    echo "Installation complete. Please log out and log back in for the group changes to take effect."
    echo "You can then launch virt-manager to manage virtual machines."
fi
