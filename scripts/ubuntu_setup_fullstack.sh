#!/bin/bash

# Fullstack Development Setup Script
# Installs Node.js, databases, Docker Compose, and web development tools

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
echo "Fullstack Development Setup"
echo "============================================"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root (don't use sudo)"
   exit 1
fi

# Install Node.js via nvm
print_info "Setting up Node.js with nvm (Node Version Manager)..."
if [ ! -d "$HOME/.nvm" ]; then
    print_info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
    
    # Load nvm in current shell
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    print_success "nvm installed"
else
    print_success "nvm already installed"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# Install latest LTS Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    print_success "Node.js already installed (version: $NODE_VERSION)"
else
    print_info "Installing Node.js LTS..."
    nvm install --lts
    nvm use --default --lts
    nvm alias default node
    print_success "Node.js LTS installed"
fi

NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
print_success "Node.js: $NODE_VERSION, npm: $NPM_VERSION"

# Install additional package managers
echo ""
print_info "Installing additional package managers..."

# Install yarn
if ! command_exists yarn; then
    print_info "Installing Yarn..."
    npm install -g yarn
    print_success "Yarn installed"
else
    print_success "Yarn already installed ($(yarn --version))"
fi

# Install pnpm
if ! command_exists pnpm; then
    print_info "Installing pnpm..."
    npm install -g pnpm
    print_success "pnpm installed"
else
    print_success "pnpm already installed ($(pnpm --version))"
fi

# Install Poetry (Python dependency manager)
if ! command_exists poetry; then
    print_info "Installing Poetry..."
    curl -sSL https://install.python-poetry.org | python3 -
    
    # Add Poetry to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    
    # Add to shell config if not already there
    if [ -f "$HOME/.zshrc" ] && ! grep -q '$HOME/.local/bin' "$HOME/.zshrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    fi
    if [ -f "$HOME/.bashrc" ] && ! grep -q '$HOME/.local/bin' "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi
    
    print_success "Poetry installed"
    print_info "Poetry has been added to PATH. Restart terminal or run: source ~/.zshrc (or ~/.bashrc)"
else
    print_success "Poetry already installed ($(poetry --version))"
fi

# Install Docker Compose
echo ""
print_info "Installing Docker Compose..."
if ! command_exists docker-compose; then
    # Check if Docker Compose plugin is available (newer method)
    if docker compose version > /dev/null 2>&1; then
        print_success "Docker Compose plugin already available"
    else
        # Install standalone Docker Compose
        DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
        print_info "Installing Docker Compose $DOCKER_COMPOSE_VERSION..."
        
        sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        
        print_success "Docker Compose installed"
    fi
else
    print_success "Docker Compose already installed"
fi

# Database installation
echo ""
print_info "Database Installation"
echo "Select which databases to install:"
echo "  1) PostgreSQL (Recommended for production)"
echo "  2) MySQL"
echo "  3) MongoDB"
echo "  4) Redis"
echo "  5) All of the above"
echo "  6) Skip database installation"
echo ""
read -p "Enter choice [1-6]: " DB_CHOICE

case $DB_CHOICE in
    1|5)
        print_info "Installing PostgreSQL..."
        sudo apt update
        sudo apt install -y postgresql postgresql-contrib
        
        print_success "PostgreSQL installed"
        print_info "Starting PostgreSQL service..."
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
        print_success "PostgreSQL service started and enabled"
        ;;
esac

case $DB_CHOICE in
    2|5)
        print_info "Installing MySQL..."
        sudo apt update
        sudo apt install -y mysql-server
        
        print_success "MySQL installed"
        print_info "Starting MySQL service..."
        sudo systemctl start mysql
        sudo systemctl enable mysql
        
        print_info "Running MySQL secure installation..."
        print_info "You may be prompted to set a root password and configure security options"
        # Note: mysql_secure_installation is interactive, so we'll just inform the user
        print_info "After this script completes, run: sudo mysql_secure_installation"
        print_success "MySQL service started and enabled"
        ;;
esac

case $DB_CHOICE in
    3|5)
        print_info "Installing MongoDB..."
        # MongoDB only publishes repos for LTS codenames (jammy/noble). Map the
        # running release to the closest supported one; default to noble (24.04).
        UBUNTU_CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
        case "$UBUNTU_CODENAME" in
            jammy) MONGO_CODENAME="jammy" ;;
            noble) MONGO_CODENAME="noble" ;;
            *)     MONGO_CODENAME="noble" ;;  # newer/unknown releases -> latest supported
        esac
        print_info "Using MongoDB repository for '$MONGO_CODENAME' (host: $UBUNTU_CODENAME)"
        # Add MongoDB 8.0 GPG key and repository
        curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
        echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu ${MONGO_CODENAME}/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
        
        sudo apt update
        sudo apt install -y mongodb-org
        
        print_success "MongoDB installed"
        print_info "Starting MongoDB service..."
        sudo systemctl start mongod
        sudo systemctl enable mongod
        print_success "MongoDB service started and enabled"
        ;;
esac

case $DB_CHOICE in
    4|5)
        print_info "Installing Redis..."
        sudo apt update
        sudo apt install -y redis-server
        
        print_success "Redis installed"
        print_info "Starting Redis service..."
        sudo systemctl start redis-server
        sudo systemctl enable redis-server
        print_success "Redis service started and enabled"
        ;;
esac

# Install nginx
echo ""
print_info "Installing nginx web server..."
if ! command_exists nginx; then
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    print_success "nginx installed and started"
    print_info "nginx is running on http://localhost"
else
    print_success "nginx already installed"
fi

# Cloud CLI tools (optional)
echo ""
read -p "Do you want to install cloud CLI tools? (AWS, Azure, GCP) (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Installing cloud CLI tools..."
    
    # AWS CLI
    if ! command_exists aws; then
        print_info "Installing AWS CLI..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
        unzip -q /tmp/awscliv2.zip -d /tmp
        sudo /tmp/aws/install
        rm -rf /tmp/aws /tmp/awscliv2.zip
        print_success "AWS CLI installed"
    else
        print_success "AWS CLI already installed"
    fi
    
    # Azure CLI
    if ! command_exists az; then
        print_info "Installing Azure CLI..."
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        print_success "Azure CLI installed"
    else
        print_success "Azure CLI already installed"
    fi
    
    # Google Cloud SDK
    if ! command_exists gcloud; then
        print_info "Installing Google Cloud SDK..."
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        # apt-key is deprecated/removed on modern Ubuntu; use a dearmored keyring instead
        curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
        sudo apt update
        sudo apt install -y google-cloud-cli
        print_success "Google Cloud SDK installed"
        print_info "Run 'gcloud init' to configure it"
    else
        print_success "Google Cloud SDK already installed"
    fi
fi

echo ""
echo "============================================"
print_success "Fullstack development setup completed!"
echo "============================================"
echo ""
echo "Installed tools:"
echo "  - Node.js $(node --version) via nvm"
echo "  - npm $(npm --version), Yarn, pnpm"
if command_exists poetry; then
    echo "  - Poetry $(poetry --version | cut -d' ' -f3)"
fi
echo "  - Docker Compose"
if [[ $DB_CHOICE =~ ^[1-5]$ ]]; then
    echo "  - Database servers (as selected)"
fi
echo "  - nginx web server"
echo ""
echo "Next steps:"
echo "  1. If databases were installed:"
echo "     - PostgreSQL: sudo -u postgres psql"
echo "     - MySQL: sudo mysql_secure_installation"
echo "     - MongoDB: mongosh"
echo "     - Redis: redis-cli"
echo ""
echo "  2. For nvm to work in new terminals, add to ~/.zshrc or ~/.bashrc:"
echo "     export NVM_DIR=\"\$HOME/.nvm\""
echo "     [ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\""
echo ""
echo "  3. Test Docker Compose: docker compose version"
echo ""

