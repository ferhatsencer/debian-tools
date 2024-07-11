#!/usr/bin/env bash

# Get the directory of the script
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
log_dir="$script_dir/logs"
mkdir -p "$log_dir" || { echo "Failed to create log directory: $log_dir"; exit 1; }

# Create downloads directory if it doesn't exist
download_dir="$script_dir/downloads"
mkdir -p "$download_dir" || { echo "Failed to create download directory: $download_dir"; exit 1; }

# Check if JetBrains Toolbox is already installed
if [ -e "/opt/jetbrains-toolbox/jetbrains-toolbox" ]; then
    echo "JetBrains Toolbox is already installed."
    exit 0
fi

# Prompt user for confirmation
read -p "Do you want to proceed with the installation of JetBrains Toolbox? [y/N]: " proceed
if [[ "$proceed" != [yY] ]]; then
    echo "Installation aborted by the user."
    exit 0
fi

# Timestamp for log file
timestamp=$(date +"%Y%m%d_%H%M%S")
installation_log="$log_dir/jetbrains_toolbox_installation_$timestamp.log"
echo "Installation Log: $(date)" > "$installation_log"

# JetBrains Toolbox download URL
toolbox_url="https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-2.3.2.31487.tar.gz"
toolbox_filename=$(basename "$toolbox_url")
toolbox_directory="jetbrains-toolbox-2.3.2.31487"

# Function to download and install JetBrains Toolbox
download_and_install_toolbox() {
    echo "Downloading JetBrains Toolbox" | tee -a "$installation_log"
    if ! wget --quiet --show-progress "$toolbox_url" -P "$download_dir" -c -O "$download_dir/$toolbox_filename" &>> "$installation_log"; then
        echo "Failed to download JetBrains Toolbox" | tee -a "$installation_log"
        exit 1
    fi

    echo "Extracting JetBrains Toolbox" | tee -a "$installation_log"
    if ! tar -xzf "$download_dir/$toolbox_filename" -C "$download_dir" &>> "$installation_log"; then
        echo "Failed to extract JetBrains Toolbox" | tee -a "$installation_log"
        exit 1
    fi

    echo "Installing JetBrains Toolbox" | tee -a "$installation_log"
    toolbox_install_dir="/opt/jetbrains-toolbox"
    sudo mkdir -p "$toolbox_install_dir"
    if ! sudo cp -R "$download_dir/$toolbox_directory"/* "$toolbox_install_dir" &>> "$installation_log"; then
        echo "Failed to install JetBrains Toolbox" | tee -a "$installation_log"
        exit 1
    fi

    echo "Creating JetBrains Toolbox symlink" | tee -a "$installation_log"
    sudo ln -sf "$toolbox_install_dir/jetbrains-toolbox" "/usr/local/bin/jetbrains-toolbox"

    echo "JetBrains Toolbox installed successfully" | tee -a "$installation_log"
}

# Install JetBrains Toolbox
download_and_install_toolbox

# Cleanup function
cleanup() {
    echo "Cleaning up downloaded files..."
    rm -rf "$download_dir"
}

trap cleanup EXIT
