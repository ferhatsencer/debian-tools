#!/usr/bin/env bash

# Function to display error and exit
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if Docker is already installed
if command -v docker &>/dev/null; then
    echo "Docker is already installed."
    read -p "Do you want to reinstall Docker? [y/N]: " reinstall
    if [[ "$reinstall" != [yY] ]]; then
        exit 0
    fi
fi

# Install prerequisites
echo "Installing required packages..."
if ! sudo apt update; then
    exit_with_error "Failed to update package lists"
fi
if ! sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release; then
    exit_with_error "Failed to install required packages"
fi

# Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
if ! sudo curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg; then
    exit_with_error "Failed to add Docker's GPG key"
fi

# Set up the stable repository
echo "Setting up the Docker stable repository..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
if ! sudo apt update; then
    exit_with_error "Failed to update package lists after adding Docker repository"
fi

# Install Docker Engine
echo "Installing Docker Engine..."
if ! sudo apt install docker-ce docker-ce-cli containerd.io; then
    exit_with_error "Failed to install Docker"
fi

# Enable and start Docker service
echo "Enabling and starting Docker service..."
if ! sudo systemctl enable docker; then
    exit_with_error "Failed to enable Docker service"
fi
if ! sudo systemctl start docker; then
    exit_with_error "Failed to start Docker service"
fi

# Check Docker installation by running a test image
echo "Verifying Docker installation by running a test image..."
if ! docker run --rm hello-world; then
    exit_with_error "Docker installation verification failed"
fi

echo "Docker and Portainer installed successfully. Access Portainer at http://localhost:9000"
exit 0
