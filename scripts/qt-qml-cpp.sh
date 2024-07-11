#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Prompt user for confirmation
read -p "Do you want to install Qt, Qt Creator, KDevelop, additional C++ packages, and QML packages? [y/N]: " proceed
if [[ "$proceed" != [yY] ]]; then
    echo "Installation aborted by the user."
    exit 0
fi

# Update package lists
if ! sudo apt update; then
    exit_with_error "Failed to update package lists"
fi

# Install Qt and Qt Creator
# if ! apt install -y qt5-qmake qtcreator; then
#     exit_with_error "Failed to install Qt and Qt Creator"
# fi

# Install necessary C++ development packages
if ! sudo apt install build-essential \
    cmake \
    gdb \
    g++ \
    clang \
    llvm \
    valgrind \
    cppcheck \
    libboost-all-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-cpp-dev \
    libjsoncpp-dev \
    libcurl4-openssl-dev \
    libgtest-dev \
    ccache; then
    exit_with_error "Failed to install necessary C++ development packages"
fi

# Install KDevelop and interested packages
if ! sudo apt install kdevelop kdevelop-python kdevelop-l10n; then
    exit_with_error "Failed to install KDevelop and interested packages"
fi

# Install QML packages
if ! sudo apt install -y \
    qmlscene \
    qml-module-qtquick2 \
    qml-module-qtquick-controls \
    qml-module-qtquick-dialogs \
    qml-module-qtgraphicaleffects \
    qml-module-qtquick-extras \
    qml-module-qtquick-layouts \
    qml-module-qtqml \
    qml-module-qtquick-extras; then
    exit_with_error "Failed to install QML packages"
fi

echo "Qt, Qt Creator, KDevelop, additional C++ packages (including ccache and GammaRay), and QML packages installed successfully."
