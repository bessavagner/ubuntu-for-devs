#!/bin/bash

# Ubuntu Post-Installation Setup Script
# Main script for essential installations
# Ubuntu >= 24.04

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root (don't use sudo)"
   exit 1
fi

echo "============================================"
echo "Ubuntu Post-Installation Setup"
echo "============================================"
echo ""

# Update package list
print_info "Updating package list..."
sudo apt update
print_success "Package list updated"

# Install git if not present
if ! command_exists git; then
    print_info "Installing git..."
    sudo apt install -y git
    print_success "Git installed"
else
    print_success "Git already installed"
fi

# Install nala for faster package management
print_info "Installing nala (faster apt replacement)..."
if ! command_exists nala; then
    sudo apt install -y nala
    print_success "Nala installed"

    print_info "Fetching fastest mirrors (this may take a moment)..."
    echo "Please select the top mirrors when prompted"
    sudo nala fetch
else
    print_success "Nala already installed"
fi

# Install essential packages
print_info "Installing essential packages..."
sudo nala install -y \
    htop fastfetch bpytop clang cargo libc6-i386 libc6-x32 \
    samba-common-bin exfat-fuse default-jdk \
    curl wget unrar linux-headers-$(uname -r) linux-headers-generic \
    git gstreamer1.0-vaapi unzip ntfs-3g p7zip gcc make bzip2 tar \
    software-properties-common

print_success "Essential packages installed"

# Install Ubuntu restricted codecs
print_info "Installing media codecs..."
sudo apt install -y ubuntu-restricted-extras
print_success "Media codecs installed"

# Install Docker
print_info "Installing Docker..."
if ! command_exists docker; then
    print_info "Adding Docker's official repository..."
    
    # Install prerequisites
    sudo apt update
    sudo apt install -y ca-certificates curl
    
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package list
    sudo apt update
    
    # Install Docker Engine, CLI, and plugins
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Start and enable Docker
    sudo systemctl enable docker
    sudo systemctl start docker

    # Configure Docker for current user
    sudo groupadd docker 2>/dev/null || true
    sudo usermod -aG docker $USER
    print_success "Docker installed from official repository"
    print_info "You'll need to log out and back in for Docker group changes to take effect"
else
    print_success "Docker already installed"
fi

# Install Gnome Tweaks
print_info "Installing Gnome Tweaks and Extensions Manager..."
sudo nala install -y gnome-tweaks gnome-shell-extension-manager
print_success "Gnome tools installed"

# Setup Flatpak
print_info "Setting up Flatpak..."
if ! command_exists flatpak; then
    sudo nala install -y flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    print_success "Flatpak installed and Flathub repository added"
else
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    print_success "Flatpak already installed, Flathub repository verified"
fi

# Install Stacer system monitor
print_info "Installing Stacer system optimizer..."
sudo nala install -y stacer
print_success "Stacer installed"

echo ""
echo "============================================"
print_success "Main setup completed!"
echo "============================================"
echo ""
echo "Optional setup scripts available:"
echo "  - ./ubuntu_setup_terminal.sh    (zsh, oh-my-zsh, plugins)"
echo "  - ./ubuntu_setup_ollama.sh      (Local LLM with DeepSeek)"
echo "  - ./ubuntu_setup_git.sh         (Git and GitHub CLI config)"
echo "  - ./ubuntu_setup_python.sh      (Additional Python versions - USE WITH CAUTION)"
echo "  - ./ubuntu_setup_claude.sh      (Claude Code CLI + curated skills/plugins)"
echo ""
echo "Note: You should log out and back in for Docker group changes to take effect"
echo "Then test Docker with: docker run hello-world"
