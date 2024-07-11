#!/usr/bin/env bash

# Get the directory of the script
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
log_dir="$script_dir/logs"
mkdir -p "$log_dir" || { echo "Failed to create log directory: $log_dir"; exit 1; }

# Create downloads directory if it doesn't exist
download_dir="$script_dir/deb_downloads"
mkdir -p "$download_dir" || { echo "Failed to create download directory: $download_dir"; exit 1; }

# Timestamp for log file
timestamp=$(date +"%Y%m%d_%H%M%S")
installation_log="$log_dir/installation_$timestamp.log"
echo "Installation Log: $(date)" > "$installation_log"

declare -A package_status
declare -A package_urls=(
    ["pinokio"]="https://github.com/pinokiocomputer/pinokio/releases/download/1.3.4/Pinokio_1.3.4_amd64.deb"
    ["boosteroid"]="https://boosteroid.com/linux/installer/boosteroid-install-x64.deb"
    ["freetube"]="https://github.com/FreeTubeApp/FreeTube/releases/download/v0.20.0-beta/freetube_0.20.0_amd64.deb"
    ["simplex"]="https://github.com/simplex-chat/simplex-chat/releases/latest/download/simplex-desktop-ubuntu-22_04-x86_64.deb"
    ["balena-etcher"]="https://github.com/balena-io/etcher/releases/download/v1.19.21/balena-etcher_1.19.21_amd64.deb"
    ["google-chrome-stable"]="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    ["localsend_app"]="https://github.com/localsend/localsend/releases/download/v1.14.0/LocalSend-1.14.0-linux-x86-64.deb"
    ["kdiskmark"]="https://github.com/JonMagon/KDiskMark/releases/download/3.1.4/kdiskmark_3.1.4-debian_amd64.deb"
    ["obsidian"]="https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/obsidian_1.6.3_amd64.deb"
    ["java"]="https://download.oracle.com/java/17/archive/jdk-17.0.10_linux-x64_bin.deb"
    ["standart-notes"]="https://github.com/standardnotes/app/releases/download/%40standardnotes%2Fdesktop%403.194.9/standard-notes-3.194.9-linux-amd64.deb"
    ["obs"]="https://github.com/obsproject/obs-studio/releases/download/30.1.2/OBS-Studio-30.1.2-Ubuntu-x86_64.deb"
    ["codium"]="https://github.com/VSCodium/vscodium/releases/download/1.91.0.24190/codium_1.91.0.24190_amd64.deb"
)

# Function to check if package is installed or has residual configuration
is_package_installed() {
    local package_name=\$1
    dpkg-query -W -f='${Status}\n' "$package_name" 2>/dev/null | grep -qE '^(install|hold) ok|^[^ ]+ [^ ]+ [^ ]+ [^ ]+residual-config'
}

# Function to download packages
download_packages() {
    for package_name in "${!package_urls[@]}"; do
        local url="${package_urls[$package_name]}"
        local deb_filename=$(basename "$url")
        local log_file="$log_dir/$deb_filename.log"

        if [[ -f "$download_dir/$deb_filename" ]]; then
            echo "$deb_filename is already downloaded" | tee -a "$installation_log"
            continue
        fi

        echo "Downloading $deb_filename" | tee -a "$installation_log"
        if ! wget --quiet --show-progress "$url" -P "$download_dir" -c -O "$download_dir/$deb_filename" &> "$log_file"; then
            echo "Failed to download $deb_filename" | tee -a "$installation_log"
        else
            echo "Successfully downloaded $deb_filename" | tee -a "$installation_log"
        fi
    done
}

# Function to install packages
install_packages() {
    for package_name in "${!package_urls[@]}"; do
        local url="${package_urls[$package_name]}"
        local deb_filename=$(basename "$url")
        local log_file="$log_dir/$deb_filename.log"

        if is_package_installed "$package_name"; then
            echo "$package_name is already installed" | tee -a "$installation_log"
            package_status[$package_name]="Already Installed"
            continue
        fi

        if [[ ! -f "$download_dir/$deb_filename" ]]; then
            echo "$deb_filename is not downloaded, skipping installation" | tee -a "$installation_log"
            package_status[$package_name]="Not Downloaded"
            continue
        fi

        echo "Installing $deb_filename" | tee -a "$installation_log"
        if sudo apt install "$download_dir/$deb_filename" 2>&1 | tee -a "$log_file"; then
            package_status[$package_name]="Success"
            echo "Installed $deb_filename successfully" | tee -a "$installation_log"
        else
            package_status[$package_name]="Failed"
            echo "Failed to install $deb_filename" | tee -a "$installation_log"
        fi

        echo "-------------------------" | tee -a "$installation_log"
    done
}

# Main execution
echo "Step 1: Downloading packages"
download_packages

echo "Step 2: Confirmation before installation"
read -p "Do you want to proceed with the installation? [y/N]: " proceed
if [[ "$proceed" != [yY] ]]; then
    echo "Installation aborted by the user."
    exit 0
fi

echo "Step 3: Installing packages"
install_packages

# Output summary of installation status
echo "Installation Summary:" | tee -a "$installation_log"
for package in "${!package_status[@]}"; do
    echo "$package: ${package_status[$package]}" | tee -a "$installation_log"
done

# Cleanup function (commented out to keep downloaded packages)
# cleanup() {
#     echo "Cleaning up downloaded files..."
#     rm -rf "$download_dir"
# }
# trap cleanup EXIT

echo "Script execution completed. Downloaded packages are kept in $download_dir"
