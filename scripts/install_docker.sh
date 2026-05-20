#!/bin/bash
###############################################################################
# Docker Installation Script
# Installs Docker and Docker Compose on Ubuntu 22.04
# This script runs as user_data during EC2 instance launch
###############################################################################

set -e  # Exit on error

echo "================================"
echo "Docker Installation Started"
echo "================================"

# Update system packages
echo "[*] Updating system packages..."
apt-get update
apt-get upgrade -y

# Install dependencies
echo "[*] Installing dependencies..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    git \
    wget

# Add Docker GPG key
echo "[*] Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "[*] Adding Docker repository..."
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install Docker
echo "[*] Installing Docker Engine..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose (latest version)
echo "[*] Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Enable Docker service
echo "[*] Enabling Docker service..."
systemctl enable docker
systemctl start docker

# Verify installation
echo "[*] Verifying Docker installation..."
docker --version
docker-compose --version

# Add ubuntu user to docker group (optional, for non-root access)
echo "[*] Adding ubuntu user to docker group..."
usermod -aG docker ubuntu || true

echo "================================"
echo "Docker Installation Completed!"
echo "================================"
echo ""
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker-compose --version)"
echo ""
echo "Note: You may need to log out and log back in for group changes to take effect"
