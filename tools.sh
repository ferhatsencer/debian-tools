#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
scripts_dir="$script_dir/scripts"

echo "Main script directory: $script_dir"
echo "Scripts directory: $scripts_dir"

if [ ! -d "$scripts_dir" ]; then
    echo "Error: Scripts directory not found at $scripts_dir"
    exit 1
fi

run_script() {
    local script_name="$1"
    echo "Attempting to run: $scripts_dir/$script_name"
    if [ -f "$scripts_dir/$script_name" ]; then
        bash "$scripts_dir/$script_name"
    else
        echo "Script $script_name not found in $scripts_dir!"
        echo "Contents of $scripts_dir:"
        ls -l "$scripts_dir"
    fi
    echo "Press any key to continue..."
    read -n 1
}

while true; do
    clear
    echo "=== Debian Tools Menu ==="
    echo "1.  Add to Sudoers"
    echo "2.  Install Default Packages"
    echo "3.  Install LibreWolf"
    echo "4.  Setup Qt/QML/C++"
    echo "5.  Setup Waydroid"
    echo "6.  Install AMDGPU Drivers"
    echo "7.  Setup Docker"
    echo "8.  Configure Resolved"
    echo "9.  Install Brave Browser"
    echo "10. Install Eddie UI"
    echo "11. Install Mullvad VPN"
    echo "12. Install Signal"
    echo "13. Install Flatpak Packages"
    echo "14. Install JetBrains Toolbox"
    echo "15. Setup ProtonVPN GUI"
    echo "16. Install QEMU/KVM"
    echo "17. Install Waterfox"
    echo "18. Install Deb Packages"
    echo "0.  Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1) run_script "add_to_sudoers.sh" ;;
        2) run_script "default_packages.sh" ;;
        3) run_script "librewolf.sh" ;;
        4) run_script "qt-qml-cpp.sh" ;;
        5) run_script "waydroid.sh" ;;
        6) run_script "amdgpu.sh" ;;
        7) run_script "docker.sh" ;;
        8) run_script "resolved.sh" ;;
        9) run_script "brave-browser.sh" ;;
        10) run_script "eddie-ui.sh" ;;
        11) run_script "mullvad.sh" ;;
        12) run_script "signal.sh" ;;
        13) run_script "flatpak_packages.sh" ;;
        14) run_script "jetbrains-toolbox.sh" ;;
        15) run_script "protonvpn-gui.sh" ;;
        16) run_script "qemu_kvm.sh" ;;
        17) run_script "waterfox.sh" ;;
        18) run_script "deb_packages.sh" ;;
        0) exit 0 ;;
        *) echo "Invalid option. Press any key to continue..."; read -n 1 ;;
    esac
done
