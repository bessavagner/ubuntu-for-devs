#!/bin/bash

# Ubuntu Terminal Optimization Setup
# Installs and configures zsh with oh-my-zsh and useful plugins

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

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "============================================"
echo "Terminal Optimization Setup"
echo "============================================"
echo ""

# Install zsh
if ! command_exists zsh; then
    print_info "Installing zsh..."
    sudo apt install -y zsh
    print_success "Zsh installed"
else
    print_success "Zsh already installed"
fi

# Install curl if not present
if ! command_exists curl; then
    print_info "Installing curl..."
    sudo apt install -y curl
    print_success "Curl installed"
fi

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_info "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh-my-zsh installed"
else
    print_success "Oh-my-zsh already installed"
fi

# Set ZSH_CUSTOM if not set
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# Install zsh-autosuggestions plugin
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_info "Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    print_success "zsh-autosuggestions installed"
else
    print_success "zsh-autosuggestions already installed"
fi

# Install zsh-syntax-highlighting plugin
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_info "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    print_success "zsh-syntax-highlighting installed"
else
    print_success "zsh-syntax-highlighting already installed"
fi

# Install zsh-autocomplete plugin (powerful autocomplete)
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autocomplete" ]; then
    print_info "Installing zsh-autocomplete plugin..."
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
    print_success "zsh-autocomplete installed"
else
    print_success "zsh-autocomplete already installed"
fi

# Install git-extras plugin (additional git commands)
if [ ! -d "$ZSH_CUSTOM/plugins/git-extras" ]; then
    print_info "Installing git-extras plugin..."
    git clone https://github.com/unixorn/git-extra-commands.git $ZSH_CUSTOM/plugins/git-extras
    print_success "git-extras installed"
else
    print_success "git-extras already installed"
fi

# Install Powerlevel10k theme (popular and feature-rich)
echo ""
print_info "Installing Powerlevel10k theme..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    print_success "Powerlevel10k theme installed"
else
    print_success "Powerlevel10k theme already installed"
fi

# Install Powerline fonts for themes
print_info "Installing Powerline fonts..."

# Fix python3-apt if broken (common after Python version changes)
if ! python3 -c "import apt_pkg" 2>/dev/null; then
    print_info "Fixing python3-apt (apt_pkg module broken)..."
    sudo apt remove --purge -y python3-apt 2>/dev/null || true
    sudo apt autoclean 2>/dev/null || true
    sudo apt install -y python3-apt 2>/dev/null || true
fi

# Try to update package list (ignore errors from cnf-update-db)
sudo apt update 2>&1 | grep -v "cnf-update-db\|apt_pkg" || true

# Install fonts-powerline (ignore errors if apt is having issues)
if sudo apt install -y fonts-powerline 2>/dev/null; then
    print_success "Powerline fonts installed"
else
    print_info "Powerline fonts installation skipped (apt may have issues, but fonts may already be installed)"
    print_info "You can install manually later with: sudo apt install fonts-powerline"
fi

# Update .zshrc with plugins and theme
if [ -f "$HOME/.zshrc" ]; then
    print_info "Configuring .zshrc with plugins and theme..."

    # Backup original .zshrc
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

    # Configure theme (Powerlevel10k)
    if ! grep -q "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" "$HOME/.zshrc"; then
        # Replace existing ZSH_THEME line or add if not present
        if grep -q "^ZSH_THEME=" "$HOME/.zshrc"; then
            sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
        else
            # Add after ZSH line if ZSH_THEME doesn't exist
            sed -i '/^ZSH=/a ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME/.zshrc"
        fi
        print_success "Theme set to Powerlevel10k"
    else
        print_success "Theme already configured"
    fi

    # Configure plugins
    # Default plugins: git, gitfast, git-extras, zsh-autosuggestions, zsh-syntax-highlighting, zsh-autocomplete
    PLUGINS_LIST="git gitfast zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete"
    
    if [ -d "$ZSH_CUSTOM/plugins/git-extras" ]; then
        PLUGINS_LIST="$PLUGINS_LIST git-extras"
    fi

    if grep -q "^plugins=(" "$HOME/.zshrc"; then
        # Replace existing plugins line
        sed -i "s/^plugins=(.*)/plugins=($PLUGINS_LIST)/" "$HOME/.zshrc"
        print_success "Plugins configured: $PLUGINS_LIST"
    else
        # Add plugins line if it doesn't exist
        sed -i "/^ZSH_THEME=/a plugins=($PLUGINS_LIST)" "$HOME/.zshrc"
        print_success "Plugins added: $PLUGINS_LIST"
    fi

    # Add helpful aliases and settings
    if ! grep -q "# Custom aliases and settings" "$HOME/.zshrc"; then
        cat >> "$HOME/.zshrc" << 'EOF'

# Custom aliases and settings
# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcm='git checkout main'
alias gcb='git checkout -b'
alias glog='git log --oneline --graph --decorate'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Useful shortcuts
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias h='history'
alias c='clear'

# Docker aliases
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias dcp='docker compose ps'

# Python aliases
alias py='python3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'
EOF
        print_success "Useful aliases added to .zshrc"
    fi
else
    print_error ".zshrc not found. Oh-my-zsh may not be properly installed."
fi

echo ""
echo "============================================"
print_success "Terminal setup completed!"
echo "============================================"
echo ""
echo "Installed components:"
echo "  ✓ zsh with oh-my-zsh"
echo "  ✓ Powerlevel10k theme (feature-rich and customizable)"
echo "  ✓ Plugins:"
echo "    - git, gitfast (Git integration)"
echo "    - git-extras (Additional Git commands)"
echo "    - zsh-autosuggestions (Command suggestions)"
echo "    - zsh-syntax-highlighting (Syntax highlighting)"
echo "    - zsh-autocomplete (Powerful autocomplete)"
echo "  ✓ Useful aliases for Git, Docker, and navigation"
echo ""
echo "Next steps:"
echo "  1. Make zsh your default shell:"
echo "     chsh -s \$(which zsh)"
echo ""
echo "  2. Log out and back in (or restart terminal)"
echo ""
echo "  3. When you first open zsh, Powerlevel10k will run a configuration wizard"
echo "     You can run it again later with: p10k configure"
echo ""
echo "  4. To reload your configuration: source ~/.zshrc"
echo ""
echo "Useful commands:"
echo "  - gs, ga, gc, gp, gl, gd, gb, gco  (Git shortcuts)"
echo "  - d, dc, dcu, dcd, dcp            (Docker shortcuts)"
echo "  - py, venv, activate               (Python shortcuts)"
