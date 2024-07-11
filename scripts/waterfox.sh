#!/usr/bin/env bash

# Get the directory of the script
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
log_dir="$script_dir/logs"
mkdir -p "$log_dir" || { echo "Failed to create log directory: $log_dir"; exit 1; }

# Create downloads directory if it doesn't exist
download_dir="$script_dir/downloads"
mkdir -p "$download_dir" || { echo "Failed to create download directory: $download_dir"; exit 1; }

# Check if the system is Debian-based
if ! grep -q "ID=debian" /etc/os-release && ! grep -q "ID_LIKE=debian" /etc/os-release; then
    echo "This script requires a Debian-based system."
    exit 1
fi

# Timestamp for log file
timestamp=$(date +"%Y%m%d_%H%M%S")
installation_log="$log_dir/waterfox_installation_$timestamp.log"
echo "Installation Log: $(date)" > "$installation_log"

# Waterfox download URL
waterfox_url="https://cdn1.waterfox.net/waterfox/releases/G6.0.16/Linux_x86_64/waterfox-G6.0.16.tar.bz2"
waterfox_filename=$(basename "$waterfox_url")
waterfox_directory="waterfox"

# Function to download and install Waterfox
download_and_install_waterfox() {
    echo "Downloading Waterfox" | tee -a "$installation_log"
    if ! wget --quiet --show-progress "$waterfox_url" -P "$download_dir" -c -O "$download_dir/$waterfox_filename" &>> "$installation_log"; then
        echo "Failed to download Waterfox" | tee -a "$installation_log"
        exit 1
    fi

    echo "Extracting Waterfox" | tee -a "$installation_log"
    if ! tar -xjf "$download_dir/$waterfox_filename" -C "$download_dir" &>> "$installation_log"; then
        echo "Failed to extract Waterfox" | tee -a "$installation_log"
        exit 1
    fi

    echo "Installing Waterfox" | tee -a "$installation_log"
    waterfox_install_dir="/opt/waterfox"
    mkdir -p "$waterfox_install_dir"
    if ! sudo cp -R "$download_dir/$waterfox_directory"/* "$waterfox_install_dir" &>> "$installation_log"; then
        echo "Failed to install Waterfox" | tee -a "$installation_log"
        exit 1
    fi

    echo "Creating Waterfox symlink" | tee -a "$installation_log"
    sudo ln -sf "$waterfox_install_dir/waterfox" "/usr/local/bin/waterfox"

    echo "Waterfox installed successfully" | tee -a "$installation_log"
}

# Function to check for updates and update Waterfox
check_and_update_waterfox() {
    echo "Checking for Waterfox updates" | tee -a "$installation_log"
    installed_version=$(/usr/local/bin/waterfox --version)
    latest_version=$(wget -qO- "$waterfox_url" | tar -xjO waterfox/application.ini | grep '^Version=' | cut -d'=' -f2)

    if [[ "$installed_version" != "$latest_version" ]]; then
        echo "A new version of Waterfox is available: $latest_version" | tee -a "$installation_log"
        read -p "Do you want to update Waterfox? [y/N]: " update_choice
        if [[ "$update_choice" == [yY] ]]; then
            download_and_install_waterfox
        else
            echo "Waterfox update skipped" | tee -a "$installation_log"
        fi
    else
        echo "Waterfox is up to date" | tee -a "$installation_log"
    fi
}

# Check if Waterfox is already installed
if command -v waterfox &> /dev/null; then
    check_and_update_waterfox
else
    # Prompt user for confirmation
    read -p "Do you want to proceed with the installation of Waterfox? [y/N]: " proceed
    if [[ "$proceed" != [yY] ]]; then
        echo "Installation aborted by the user."
        exit 0
    fi

    # Install Waterfox
    download_and_install_waterfox
fi

# Cleanup function
cleanup() {
    echo "Cleaning up downloaded files..."
    rm -rf "$download_dir"
}

trap cleanup EXIT
