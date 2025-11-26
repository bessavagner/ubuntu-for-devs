#!/bin/bash

# Python Additional Versions Setup Script
# ⚠️  PROCEED WITH CAUTION ⚠️
# This script installs additional Python versions and configures alternatives
# This can affect system stability if not done correctly

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

print_warning() {
    echo -e "${RED}${BOLD}⚠️  WARNING: $1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "============================================"
echo "Python Additional Versions Setup"
echo "============================================"
echo ""

print_warning "This script modifies system Python configuration!"
print_warning "Incorrect usage can break system tools!"
echo ""
read -p "Are you sure you want to continue? (yes/no) " -r
echo ""
if [[ ! $REPLY == "yes" ]]; then
    print_info "Installation cancelled"
    exit 0
fi

# Check current Python version
SYSTEM_PYTHON_VERSION=$(python3 -V 2>&1 | awk '{print $2}' | cut -d. -f1,2)
SYSTEM_PYTHON_MAJOR=$(echo $SYSTEM_PYTHON_VERSION | cut -d. -f1)
SYSTEM_PYTHON_MINOR=$(echo $SYSTEM_PYTHON_VERSION | cut -d. -f2)

echo ""
print_info "Current system Python version: $SYSTEM_PYTHON_VERSION"
echo ""

# Ask which Python version to install
echo "Available Python versions:"
echo "  1) Python 3.9"
echo "  2) Python 3.10"
echo "  3) Python 3.11"
echo "  4) Python 3.12"
echo "  5) Python 3.13"
echo ""
read -p "Enter the number of the Python version you want to install: " VERSION_CHOICE

case $VERSION_CHOICE in
    1) NEW_PYTHON_VERSION="3.9" ;;
    2) NEW_PYTHON_VERSION="3.10" ;;
    3) NEW_PYTHON_VERSION="3.11" ;;
    4) NEW_PYTHON_VERSION="3.12" ;;
    5) NEW_PYTHON_VERSION="3.13" ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_info "Installing Python $NEW_PYTHON_VERSION..."

# Add deadsnakes PPA
if ! grep -q "deadsnakes/ppa" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    print_info "Adding deadsnakes PPA..."
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt update
    print_success "PPA added"
else
    print_success "deadsnakes PPA already added"
fi

# Check if the Python version is available
print_info "Checking if Python $NEW_PYTHON_VERSION is available..."
if apt-cache search "^python${NEW_PYTHON_VERSION}$" | grep -q "python${NEW_PYTHON_VERSION}"; then
    print_success "Python $NEW_PYTHON_VERSION is available"
else
    print_error "Python $NEW_PYTHON_VERSION is not available in the repository"
    exit 1
fi

# Install the new Python version and essentials
print_info "Installing Python $NEW_PYTHON_VERSION and essential packages..."

# Build package list
PACKAGES="python${NEW_PYTHON_VERSION} python${NEW_PYTHON_VERSION}-dev python${NEW_PYTHON_VERSION}-venv"

# distutils was removed in Python 3.12+, only install for older versions
PYTHON_MAJOR=$(echo $NEW_PYTHON_VERSION | cut -d. -f1)
PYTHON_MINOR=$(echo $NEW_PYTHON_VERSION | cut -d. -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -le 11 ]); then
    # Check if distutils package exists before adding it
    if apt-cache search "^python${NEW_PYTHON_VERSION}-distutils$" | grep -q "python${NEW_PYTHON_VERSION}-distutils"; then
        PACKAGES="$PACKAGES python${NEW_PYTHON_VERSION}-distutils"
        print_info "Including distutils (Python < 3.12)"
    fi
else
    print_info "Skipping distutils (removed in Python 3.12+)"
fi

sudo apt install -y $PACKAGES

print_success "Python $NEW_PYTHON_VERSION installed"

# Fix gnome-terminal
print_info "Protecting gnome-terminal from Python version changes..."
GNOME_TERMINAL="/usr/bin/gnome-terminal"
if [ -f "$GNOME_TERMINAL" ]; then
    sudo cp "$GNOME_TERMINAL" "${GNOME_TERMINAL}.backup"
    sudo sed -i "1s|#!/usr/bin/python3|#!/usr/bin/python${SYSTEM_PYTHON_VERSION}|" "$GNOME_TERMINAL"
    print_success "gnome-terminal updated to use Python $SYSTEM_PYTHON_VERSION"
fi

# Update alternatives
print_info "Setting up Python alternatives..."

# Add system Python to alternatives
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${SYSTEM_PYTHON_VERSION} 1 2>/dev/null || true

# Add new Python to alternatives
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${NEW_PYTHON_VERSION} 2 2>/dev/null || true

print_success "Python alternatives configured"

# Ask user which version to set as default
echo ""
print_info "Select which Python version to use as default:"
sudo update-alternatives --config python3

# Fix python3-apt
print_info "Fixing python3-apt..."
sudo apt remove --purge -y python3-apt
sudo apt autoclean
sudo apt install -y python3-apt
print_success "python3-apt fixed"

# Install pip for the new Python version
print_info "Installing pip for Python $NEW_PYTHON_VERSION..."

# Python 3.12+ includes ensurepip, use that instead of get-pip.py
if [ "$PYTHON_MAJOR" -gt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 12 ]); then
    # Python 3.12+ has ensurepip built-in
    print_info "Using ensurepip (built-in for Python 3.12+)"
    sudo python${NEW_PYTHON_VERSION} -m ensurepip --upgrade 2>/dev/null || true
    # Also try for system Python if it's 3.12+
    if [ "$SYSTEM_PYTHON_MINOR" -ge 12 ] 2>/dev/null; then
        sudo python${SYSTEM_PYTHON_VERSION} -m ensurepip --upgrade 2>/dev/null || true
    fi
else
    # For older Python versions, use get-pip.py
    if [ ! -f "/tmp/get-pip.py" ]; then
        curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
    fi
    sudo python${SYSTEM_PYTHON_VERSION} /tmp/get-pip.py 2>/dev/null || true
    sudo python${NEW_PYTHON_VERSION} /tmp/get-pip.py 2>/dev/null || true
fi

print_success "pip installed for Python versions"

echo ""
print_warning "DO NOT RUN 'sudo apt autoremove' as it may remove important packages!"
echo ""

echo "============================================"
print_success "Python setup completed!"
echo "============================================"
echo ""
echo "Installed Python versions:"
ls -la /usr/bin/python3.* 2>/dev/null | grep -v "python3.py" | awk '{print $9}'
echo ""
echo "Current default Python 3:"
python3 --version
echo ""
echo "To switch between versions, use:"
echo "  sudo update-alternatives --config python3"
echo ""
echo "When creating virtual environments, specify the version:"
echo "  python${NEW_PYTHON_VERSION} -m venv myenv"
echo ""
print_warning "Remember: DO NOT run 'sudo apt autoremove'"
