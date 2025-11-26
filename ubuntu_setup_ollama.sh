#!/bin/bash

# Ollama Setup Script
# Installs Ollama for running local LLMs and sets up DeepSeek with Web UI

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
echo "Ollama Setup for Local LLMs"
echo "============================================"
echo ""

# Install Ollama
if ! command_exists ollama; then
    print_info "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    print_success "Ollama installed"
else
    print_success "Ollama already installed"
fi

# Start and enable Ollama service
print_info "Starting Ollama service..."
sudo systemctl start ollama
sudo systemctl enable ollama
print_success "Ollama service started and enabled"

# Model selection menu
echo ""
print_info "Recommended LLM Models for RTX 4060 (8GB VRAM):"
echo ""
echo "Best Fit Models (7B-8B, ~4-5GB each):"
echo "  1) DeepSeek-R1:7b          - Best reasoning & coding (~4.5GB)"
echo "  2) Llama 3.1:8b            - Best general purpose (~4.7GB)"
echo "  3) CodeLlama:7b            - Best for coding tasks (~4.5GB)"
echo "  4) Qwen2.5:7b              - Best multilingual support (~4.5GB)"
echo "  5) Mistral:7b              - Fast responses (~4.1GB)"
echo ""
echo "Larger Models (13B-14B, ~7-8GB, tight fit):"
echo "  6) Llama 3.1:13b           - Best quality (~7.2GB)"
echo "  7) Qwen2.5:14b             - Best multilingual quality (~7.8GB)"
echo ""
echo "  8) Download all recommended (1-5)"
echo "  9) Custom model (enter name manually)"
echo "  0) Skip model download"
echo ""
read -p "Select models to download (comma-separated, e.g., 1,2,3 or 8 for all): " MODEL_CHOICE
echo ""

# Function to download a model
download_model() {
    local model_name=$1
    local model_display=$2
    
    print_info "Downloading $model_display (this may take several minutes)..."
    if ollama pull "$model_name"; then
        print_success "$model_display downloaded successfully"
        return 0
    else
        print_error "Failed to download $model_display"
        return 1
    fi
}

# Process model selections
IFS=',' read -ra SELECTIONS <<< "$MODEL_CHOICE"
DOWNLOADED_COUNT=0

for choice in "${SELECTIONS[@]}"; do
    choice=$(echo "$choice" | xargs) # Trim whitespace
    
    case $choice in
        1)
            download_model "deepseek-r1:7b" "DeepSeek-R1:7b"
            ((DOWNLOADED_COUNT++))
            ;;
        2)
            download_model "llama3.1:8b" "Llama 3.1:8b"
            ((DOWNLOADED_COUNT++))
            ;;
        3)
            download_model "codellama:7b" "CodeLlama:7b"
            ((DOWNLOADED_COUNT++))
            ;;
        4)
            download_model "qwen2.5:7b" "Qwen2.5:7b"
            ((DOWNLOADED_COUNT++))
            ;;
        5)
            download_model "mistral:7b" "Mistral:7b"
            ((DOWNLOADED_COUNT++))
            ;;
        6)
            print_info "Llama 3.1:13b requires ~7.2GB VRAM - ensure no other GPU apps are running"
            read -p "Continue with download? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                download_model "llama3.1:13b" "Llama 3.1:13b"
                ((DOWNLOADED_COUNT++))
            fi
            ;;
        7)
            print_info "Qwen2.5:14b requires ~7.8GB VRAM - ensure no other GPU apps are running"
            read -p "Continue with download? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                download_model "qwen2.5:14b" "Qwen2.5:14b"
                ((DOWNLOADED_COUNT++))
            fi
            ;;
        8)
            print_info "Downloading all recommended models (1-5)..."
            download_model "deepseek-r1:7b" "DeepSeek-R1:7b"
            download_model "llama3.1:8b" "Llama 3.1:8b"
            download_model "codellama:7b" "CodeLlama:7b"
            download_model "qwen2.5:7b" "Qwen2.5:7b"
            download_model "mistral:7b" "Mistral:7b"
            DOWNLOADED_COUNT=5
            ;;
        9)
            echo ""
            read -p "Enter model name (e.g., phi3:14b, neural-chat:7b): " CUSTOM_MODEL
            if [ -n "$CUSTOM_MODEL" ]; then
                download_model "$CUSTOM_MODEL" "$CUSTOM_MODEL"
                ((DOWNLOADED_COUNT++))
            fi
            ;;
        0)
            print_info "Skipping model downloads"
            ;;
        *)
            if [ -n "$choice" ]; then
                print_error "Invalid choice: $choice"
            fi
            ;;
    esac
done

if [ $DOWNLOADED_COUNT -gt 0 ]; then
    echo ""
    print_success "$DOWNLOADED_COUNT model(s) downloaded"
    print_info "View all models with: ollama list"
fi

# Ask user if they want to set up Web UI
echo ""
read -p "Do you want to set up Ollama Web UI (Open WebUI)? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Setting up Open WebUI..."

    # Install python3-venv if not present
    if ! dpkg -l | grep -q python3-venv; then
        print_info "Installing python3-venv..."
        sudo apt install -y python3-venv
    fi

    # Create virtual environment
    VENV_PATH="$HOME/open-webui-venv"
    if [ ! -d "$VENV_PATH" ]; then
        print_info "Creating virtual environment at $VENV_PATH..."
        python3 -m venv "$VENV_PATH"
        print_success "Virtual environment created"
    else
        print_success "Virtual environment already exists"
    fi

    # Install open-webui
    print_info "Installing Open WebUI in virtual environment..."
    source "$VENV_PATH/bin/activate"
    pip install --upgrade pip
    pip install open-webui
    deactivate
    print_success "Open WebUI installed"

    # Create a launcher script
    LAUNCHER="$HOME/start-ollama-webui.sh"
    cat > "$LAUNCHER" << 'EOF'
#!/bin/bash
echo "Starting Ollama Web UI..."
echo "Access the interface at: http://localhost:8080"
echo "Press Ctrl+C to stop"
source ~/open-webui-venv/bin/activate
open-webui serve
EOF
    chmod +x "$LAUNCHER"
    print_success "Launcher script created at: $LAUNCHER"

    echo ""
    print_info "To start the Web UI, run: $LAUNCHER"
    print_info "Then open your browser to: http://localhost:8080"

    # Ask if user wants to start it now
    echo ""
    read -p "Do you want to start the Web UI now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Starting Web UI... (Press Ctrl+C to stop)"
        bash "$LAUNCHER"
    fi
else
    print_info "Skipping Web UI setup"
fi

echo ""
echo "============================================"
print_success "Ollama setup completed!"
echo "============================================"
echo ""
echo "Available commands:"
echo "  - ollama list                    (List downloaded models)"
echo "  - ollama run <model>            (Run a model in terminal)"
echo "  - ollama pull <model>            (Download a model)"
echo "  - ollama show <model>            (Show model information)"
echo ""
echo "Example usage:"
echo "  ollama run deepseek-r1:7b \"Explain quantum computing\""
echo "  ollama run llama3.1:8b \"Write a Python function\""
echo "  ollama run codellama:7b \"Create a REST API\""
echo ""
if [ -f "$HOME/start-ollama-webui.sh" ]; then
    echo "Web UI:"
    echo "  - $HOME/start-ollama-webui.sh    (Start Web UI)"
    echo "  - Then open: http://localhost:8080"
    echo ""
fi
echo "For more model recommendations, see: LLM_RECOMMENDATIONS.md"
