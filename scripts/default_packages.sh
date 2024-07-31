#!/usr/bin/env bash

# Prompt for the username
read -p 'Enter the username: ' username

# Validate the username input
if ! [[ "$username" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Invalid username. Only alphanumeric characters and underscores are allowed." 1>&2
    exit 1
fi

echo ""

# Function to install packages
install_packages() {
    local installed_packages=()
    local packages_to_install=()

    # Loop through provided package names
    for pkg in "$@"; do
        # Check if the package is already installed
        if ! dpkg -l "$pkg" &>/dev/null; then
            packages_to_install+=("$pkg")
        else
            installed_packages+=("$pkg")
        fi
    done

    # Install packages if any are not installed
    if [ ${#packages_to_install[@]} -gt 0 ]; then
        if ! sudo apt install -y "${packages_to_install[@]}"; then
            echo "Failed to install packages. Please check your internet connection and try again."
            return 1
        fi
        echo "Packages installed successfully: ${packages_to_install[@]}"
    else
        echo "All specified packages are already installed: ${installed_packages[@]}"
    fi
}

# List of packages to install, organized by category
# System Utilities
system_utilities_packages=(
    systemd-resolved
    pipewire
    pipewire-audio
    lm-sensors
    curl
    wget
    ca-certificates
    axel
    cmake
    qpwgraph
    cpu-x
    exfatprogs
    exfat-fuse
)

# Development Tools
development_tools_packages=(
    adb
    fastboot
    android-platform-tools-base
    android-sdk-platform-tools-common
)

# Communication and Productivity
communication_productivity_packages=(
    telegram-desktop
    neochat
    itinerary
    kontact
    konversation
    krdc
    parley
    pidgin
    pidgin-plugin-pack
)

# Multimedia
multimedia_packages=(
    vlc
    sweeper
    qdirstat
    youtubedl-gui
    digikam
    krita
    gimp
    gpredict
    marble
    kdenlive
    kphotoalbum
    elisa
    kamoso
)

# Education
education_packages=(
    kmymoney
    kstars
    kmplot
    skrooge
    kronometer
    filelight
    kolourpaint
    kalzium
    kgeography
    kturtle
    bomber
    khangman
    ktimetracker
    qmlkonsole
    konquest
    kuiviewer
    massif-visualizer
    kile
    killbots
    kimagemapeditor
    klettres
    kst
    minder
    marknote
)

# System Tools
system_tools_packages=(
    bleachbit
    gconf-service
    gconf2 #balena-dependency
    gconf2-common #balena-dependency
    libgconf-2-4 #balena-dependency
    gconf-defaults-service #balena-dependency
    #linux-cpupower
    kget
    kdiff3
    kompare
    labplot
    kdiff3
    kbruch
    ktorrent
    kcachegrind
    pdfarranger
    qbittorrent
    python-is-python3
    python3-venv
    python3-pip
    udftools
    mlocate
    #exfat fuse packages
    libfuse*
    #ntfs packages
    ntfs*
)

# Function to handle errors
function exit_with_error {
    echo "$1" 1>&2
    exit 1
}

# Prompt user for confirmation
read -p "This script will install the specified packages. Do you want to proceed? [y/N] " confirm
if [[ $confirm != [yY] ]]; then
    echo "Aborted by user."
    exit 0
fi

# Install packages
install_packages "${system_utilities_packages[@]}" "${development_tools_packages[@]}" "${communication_productivity_packages[@]}" "${multimedia_packages[@]}" "${education_packages[@]}" "${system_tools_packages[@]}"

echo ""

# Add user to plugdev group using $USER
echo "Checking if user $username is already in the plugdev group..."
if groups $username | grep -qw plugdev; then
    echo "User $username is already a member of plugdev."
else
    echo "Adding user $username to plugdev group..."
    if ! sudo usermod -a -G plugdev $username; then
        exit_with_error "Failed to add user $username to plugdev group"
    fi
    echo "User $username added to plugdev group successfully."
fi

# Add timestamp to log file
echo "Script executed on $(date)" >> script_log.txt
