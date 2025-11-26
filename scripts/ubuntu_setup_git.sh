#!/bin/bash

# Git and GitHub Configuration Script
# Sets up git configuration and GitHub CLI

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
echo "Git and GitHub Configuration"
echo "============================================"
echo ""

# Install git if not present
if ! command_exists git; then
    print_info "Installing git..."
    sudo apt install -y git
    print_success "Git installed"
else
    print_success "Git already installed"
fi

# Configure git user name and email
echo ""
print_info "Git Configuration"
echo ""

CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -n "$CURRENT_NAME" ]; then
    echo "Current git user.name: $CURRENT_NAME"
    read -p "Keep this name? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter your name for git commits: " GIT_NAME
        git config --global user.name "$GIT_NAME"
        print_success "Git user.name updated"
    fi
else
    read -p "Enter your name for git commits: " GIT_NAME
    git config --global user.name "$GIT_NAME"
    print_success "Git user.name set"
fi

if [ -n "$CURRENT_EMAIL" ]; then
    echo "Current git user.email: $CURRENT_EMAIL"
    read -p "Keep this email? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter your email for git commits: " GIT_EMAIL
        git config --global user.email "$GIT_EMAIL"
        print_success "Git user.email updated"
    fi
else
    read -p "Enter your email for git commits: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
    print_success "Git user.email set"
fi

# Install GitHub CLI
echo ""
if ! command_exists gh; then
    print_info "Installing GitHub CLI (gh)..."

    # Install wget if not present
    if ! command_exists wget; then
        sudo apt update && sudo apt-get install -y wget
    fi

    # Add GitHub CLI repository and install
    sudo mkdir -p -m 755 /etc/apt/keyrings
    out=$(mktemp)
    wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg
    cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
    rm -f $out

    print_success "GitHub CLI installed"
else
    print_success "GitHub CLI already installed"
fi

# Authenticate with GitHub
echo ""
read -p "Do you want to authenticate with GitHub now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Starting GitHub authentication..."
    print_info "When prompted, select HTTPS as the protocol"
    print_info "And select Y to authenticate Git with GitHub credentials"
    echo ""
    gh auth login
    print_success "GitHub authentication completed"
else
    print_info "Skipping GitHub authentication"
    print_info "You can authenticate later with: gh auth login"
fi

echo ""
echo "============================================"
print_success "Git and GitHub setup completed!"
echo "============================================"
echo ""
echo "Current configuration:"
git config --global user.name
git config --global user.email
echo ""
echo "Useful commands:"
echo "  - gh auth status              (Check authentication status)"
echo "  - gh repo create              (Create a new repository)"
echo "  - gh repo clone <owner/repo>  (Clone a repository)"
echo "  - git config --global -l      (View all git configurations)"
