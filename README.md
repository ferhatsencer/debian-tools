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
18. **waydroid.sh**: Set up Waydroid

## Project Structure

debian-tools/
│
├── tools.sh              # Main script to run all tools
├── README.md             # This file
├── LICENSE               # License file
├── .gitignore            # Git ignore file
│
├── scripts/              # Directory containing all tool scripts
│   ├── add_to_sudoers.sh
│   ├── amdgpu.sh
│   ├── brave-browser.sh
│   ├── deb_packages.sh
│   ├── default_packages.sh
│   ├── docker.sh
│   ├── eddie-ui.sh
│   ├── flatpak_packages.sh
│   ├── jetbrains-toolbox.sh
│   ├── librewolf.sh
│   ├── mullvad.sh
│   ├── protonvpn-gui.sh
│   ├── qemu_kvm.sh
│   ├── qt-qml-cpp.sh
│   ├── resolved.sh
│   ├── signal.sh
│   ├── waterfox.sh
│   └── waydroid.sh
│
├── deb_downloads/        # Directory for temporary .deb downloads
│   └── .gitkeep
│
└── logs/                 # Directory for log files
└── .gitkeep


## Contributing

Contributions are welcome!
