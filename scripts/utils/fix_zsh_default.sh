#!/bin/bash

# Fix zsh as default shell
# This script ensures zsh is set as the default shell and configures gnome-terminal to use it

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

echo "============================================"
echo "Fix zsh as Default Shell"
echo "============================================"
echo ""

# Check if zsh is installed
if ! command -v zsh >/dev/null 2>&1; then
    print_error "zsh is not installed"
    echo "Install with: sudo apt install zsh"
    exit 1
fi

ZSH_PATH=$(which zsh)
print_info "Found zsh at: $ZSH_PATH"

# Check if zsh is in /etc/shells
if ! grep -q "$ZSH_PATH" /etc/shells; then
    print_info "Adding zsh to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    print_success "zsh added to /etc/shells"
else
    print_success "zsh is already in /etc/shells"
fi

# Set zsh as default shell
CURRENT_SHELL=$(getent passwd $USER | cut -d: -f7)
if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    print_info "Changing default shell from $CURRENT_SHELL to $ZSH_PATH..."
    chsh -s "$ZSH_PATH"
    print_success "Default shell changed to zsh"
    echo ""
    print_info "You need to log out and back in for this to take effect"
else
    print_success "Default shell is already set to zsh"
fi

# Check gnome-terminal custom command
echo ""
print_info "Checking gnome-terminal configuration..."

# Try to get default profile
DEFAULT_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'" || echo "")

if [ -n "$DEFAULT_PROFILE" ]; then
    PROFILE_PATH="/org/gnome/terminal/legacy/profiles:/:${DEFAULT_PROFILE}/"
    
    CUSTOM_CMD=$(gsettings get org.gnome.Terminal.Legacy.Profile:"$PROFILE_PATH" custom-command 2>/dev/null || echo "''")
    
    if [ "$CUSTOM_CMD" != "''" ] && [ -n "$CUSTOM_CMD" ]; then
        print_info "Found custom command: $CUSTOM_CMD"
        echo ""
        read -p "Do you want to remove the custom command and use default shell? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gsettings set org.gnome.Terminal.Legacy.Profile:"$PROFILE_PATH" custom-command ''
            gsettings set org.gnome.Terminal.Legacy.Profile:"$PROFILE_PATH" use-custom-command false
            print_success "Custom command removed - terminal will use default shell (zsh)"
        fi
    else
        print_success "No custom command set - terminal will use default shell"
    fi
else
    print_info "Could not detect gnome-terminal profile (this is okay)"
fi

echo ""
echo "============================================"
echo "Summary"
echo "============================================"
echo ""
echo "Default shell: $(getent passwd $USER | cut -d: -f7)"
echo ""
echo "To apply changes:"
echo "  1. Log out and log back in (recommended)"
echo "  2. Or close all terminal windows and open a new one"
echo ""
echo "To test immediately, run: zsh"


