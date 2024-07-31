# Debian Tools

A collection of shell scripts for managing and setting up a Debian-based system. This toolkit provides easy-to-use scripts for various system administration tasks, software installations, and configurations.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Available Scripts](#available-scripts)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## Installation

Clone this repository to your local machine:

bash
git clone https://github.com/yourusername/debian-tools.git
cd debian-tools


Make sure the main script is executable:

bash
chmod +x tools.sh
chmod +x scripts/*.sh


## Usage

Run the main script:

bash
./tools.sh


This will present a menu of available tools. Select the number corresponding to the script you want to run.

## Available Scripts

1. **add_to_sudoers.sh**: Add a user to the sudoers file
2. **amdgpu.sh**: Install AMD GPU drivers
3. **brave-browser.sh**: Install Brave browser
4. **deb_packages.sh**: Install various .deb packages
5. **default_packages.sh**: Install a set of default packages
6. **docker.sh**: Install and set up Docker
7. **eddie-ui.sh**: Install Eddie UI
8. **flatpak_packages.sh**: Install Flatpak packages
9. **jetbrains-toolbox.sh**: Install JetBrains Toolbox
10. **librewolf.sh**: Install LibreWolf browser
11. **mullvad-vpn.sh**: Install Mullvad VPN
12. **protonvpn-gui.sh**: Install ProtonVPN GUI
13. **qemu_kvm.sh**: Set up QEMU/KVM
14. **qt-qml-cpp.sh**: Set up Qt/QML/C++ development environment
15. **resolved.sh**: Configure systemd-resolved
16. **signal.sh**: Install Signal messenger
17. **waterfox.sh**: Install Waterfox browser
18. **waydroid.sh**: Install up Waydroid
19. **ivpn.sh**: Install up IVpn
20. **unityhub.sh**: Install up Unityhub

## Project Structure

This repository is organized as follows:

- **debian-tools/**: Root directory.
  - **tools.sh**: Main script to run all tools.
  - **README.md**: Documentation for the project.
  - **LICENSE**: License file.
  - **.gitignore**: Specifies intentionally untracked files to ignore.

- **scripts/**: Contains all tool scripts.
  - **add_to_sudoers.sh**: Script to add users to sudoers.
  - **amdgpu.sh**: AMD GPU installation and configuration script.
  - **brave-browser.sh**: Script to install Brave browser.
  - **deb_packages.sh**: Script for installing .deb packages.
  - **default_packages.sh**: Script for installing default packages.
  - **docker.sh**: Docker installation and configuration script.
  - **eddie-ui.sh**: Installation script for Eddie UI.
  - **flatpak_packages.sh**: Script for installing Flatpak packages.
  - **jetbrains-toolbox.sh**: Script to install JetBrains Toolbox.
  - **librewolf.sh**: Script to install LibreWolf browser.
  - **mullvad.sh**: Mullvad VPN installation script.
  - **protonvpn-gui.sh**: ProtonVPN GUI installation script.
  - **qemu_kvm.sh**: QEMU and KVM installation script.
  - **qt-qml-cpp.sh**: Setup script for Qt, QML, and C++.
  - **resolved.sh**: Systemd-resolved configuration script.
  - **signal.sh**: Signal messenger installation script.
  - **waterfox.sh**: Waterfox browser installation script.
  - **waydroid.sh**: Waydroid installation and setup script.
  - **IVpn.sh**: IVpn installation and setup script.
  - **unityhub.sh**: unityhub installation and setup script.

- **deb_downloads/**: Directory for temporary .deb file downloads.
  - **.gitkeep**: File to keep the directory in version control.

- **logs/**: Directory for storing log files.
  - **.gitkeep**: File to keep the directory in version control.

## Contributing

Contributions are welcome!
