#!/bin/bash

# Add LLM integration to terminal
# This script adds convenient commands and functions for using Ollama LLMs directly in terminal

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
echo "Add LLM to Terminal"
echo "============================================"
echo ""

# Check if Ollama is installed
if ! command -v ollama >/dev/null 2>&1; then
    print_error "Ollama is not installed"
    echo "Install it with: ./ubuntu_setup_ollama.sh"
    exit 1
fi

print_success "Ollama found: $(ollama --version)"

# Check available models
print_info "Checking available models..."
MODELS=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | grep -v "^$" || echo "")
if [ -z "$MODELS" ]; then
    print_error "No models found. Install models with: ollama pull <model-name>"
    echo "Recommended: ollama pull deepseek-r1:7b"
    exit 1
fi

print_success "Found models:"
echo "$MODELS" | while read model; do
    echo "  - $model"
done

# Get default model (first one or ask user)
DEFAULT_MODEL=$(echo "$MODELS" | head -n 1)
if [ -z "$DEFAULT_MODEL" ]; then
    print_error "No models available"
    exit 1
fi

echo ""
read -p "Set default model [$DEFAULT_MODEL]: " USER_MODEL
DEFAULT_MODEL=${USER_MODEL:-$DEFAULT_MODEL}

# Add LLM functions to .zshrc
if [ -f "$HOME/.zshrc" ]; then
    print_info "Adding LLM functions to .zshrc..."
    
    # Remove existing LLM block if present
    sed -i '/# >>> LLM Terminal Integration >>>/,/# <<< LLM Terminal Integration <<</d' "$HOME/.zshrc" 2>/dev/null || true
    
    # Add LLM functions
    cat >> "$HOME/.zshrc" << EOF

# >>> LLM Terminal Integration >>>
# Default LLM model
export DEFAULT_LLM_MODEL="$DEFAULT_MODEL"

# Quick LLM chat - just type 'llm "your question"'
llm() {
    if [ -z "\$1" ]; then
        echo "Usage: llm \"your question\""
        echo "Or: llm (for interactive mode)"
        echo ""
        echo "Available models:"
        ollama list 2>/dev/null | tail -n +2 | awk '{print "  - " \$1}'
        return 1
    fi
    
    local model=\${LLM_MODEL:-\$DEFAULT_LLM_MODEL}
    echo -e "\${BLUE}🤖 Using model: \$model\${NC}"
    echo ""
    ollama run "\$model" "\$@"
}

# Interactive LLM chat session
llm-chat() {
    local model=\${LLM_MODEL:-\$DEFAULT_LLM_MODEL}
    echo -e "\${BLUE}🤖 Starting chat with: \$model\${NC}"
    echo -e "\${YELLOW}Type 'exit', 'quit', or Ctrl+D to end session\${NC}"
    echo ""
    ollama run "\$model"
}

# List available models
llm-list() {
    echo "Available LLM models:"
    ollama list
}

# Switch default model for current session
llm-use() {
    if [ -z "\$1" ]; then
        echo "Usage: llm-use <model-name>"
        echo "Example: llm-use deepseek-r1:7b"
        echo ""
        llm-list
        return 1
    fi
    export LLM_MODEL="\$1"
    echo "Using model: \$LLM_MODEL for this session"
    echo "To make permanent, update DEFAULT_LLM_MODEL in ~/.zshrc"
}

# Pull a new model
llm-pull() {
    if [ -z "\$1" ]; then
        echo "Usage: llm-pull <model-name>"
        echo "Example: llm-pull llama3.1:8b"
        return 1
    fi
    echo "Downloading model: \$1"
    ollama pull "\$1"
}

# Show current model info
llm-info() {
    local model=\${LLM_MODEL:-\$DEFAULT_LLM_MODEL}
    echo "Current model: \$model"
    ollama show "\$model" 2>/dev/null || echo "Model info not available"
}

# Quick code explanation
llm-explain() {
    if [ -z "\$1" ]; then
        echo "Usage: llm-explain <code or file>"
        echo "Example: llm-explain script.py"
        echo "Example: llm-explain 'def hello(): print(\"world\")'"
        return 1
    fi
    
    local model=\${LLM_MODEL:-\$DEFAULT_LLM_MODEL}
    local prompt=""
    
    if [ -f "\$1" ]; then
        prompt="Explain this code:\n\$(cat \$1)"
    else
        prompt="Explain this code: \$1"
    fi
    
    echo -e "\${BLUE}🤖 Explaining with: \$model\${NC}"
    echo ""
    echo -e "\$prompt" | ollama run "\$model"
}

# Quick code review
llm-review() {
    if [ -z "\$1" ]; then
        echo "Usage: llm-review <file>"
        echo "Example: llm-review script.py"
        return 1
    fi
    
    if [ ! -f "\$1" ]; then
        echo "Error: File not found: \$1"
        return 1
    fi
    
    local model=\${LLM_MODEL:-\$DEFAULT_LLM_MODEL}
    local prompt="Review this code and suggest improvements:\n\$(cat \$1)"
    
    echo -e "\${BLUE}🤖 Reviewing with: \$model\${NC}"
    echo ""
    echo -e "\$prompt" | ollama run "\$model"
}

# Quick translation
llm-translate() {
    if [ -z "\$2" ]; then
        echo "Usage: llm-translate <text> <target-language>"
        echo "Example: llm-translate 'Hello world' Spanish"
        return 1
    fi
    
    local model=\${LLM_MODEL:-\$DEFAULT_LLM_MODEL}
    local text="\$1"
    local target="\$2"
    
    echo -e "\${BLUE}🤖 Translating with: \$model\${NC}"
    echo ""
    ollama run "\$model" "Translate the following text to \$target: \$text"
}

# Color codes for zsh
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'
# <<< LLM Terminal Integration <<<
EOF

    print_success "LLM functions added to .zshrc"
    
    # Also add to .bashrc for bash users
    if [ -f "$HOME/.bashrc" ]; then
        print_info "Adding LLM functions to .bashrc..."
        sed -i '/# >>> LLM Terminal Integration >>>/,/# <<< LLM Terminal Integration <<</d' "$HOME/.bashrc" 2>/dev/null || true
        cat >> "$HOME/.bashrc" << EOF

# >>> LLM Terminal Integration >>>
export DEFAULT_LLM_MODEL="$DEFAULT_MODEL"

llm() {
    if [ -z "\$1" ]; then
        echo "Usage: llm \"your question\""
        echo "Or: llm (for interactive mode)"
        ollama list 2>/dev/null | tail -n +2 | awk '{print "  - " \$1}'
        return 1
    fi
    local model=\${LLM_MODEL:-\$DEFAULT_LLM_MODEL}
    echo "🤖 Using model: \$model"
    ollama run "\$model" "\$@"
}

llm-chat() {
    local model=\${LLM_MODEL:-\$DEFAULT_LLM_MODEL}
    echo "🤖 Starting chat with: \$model"
    ollama run "\$model"
}

llm-list() {
    ollama list
}

llm-use() {
    if [ -z "\$1" ]; then
        echo "Usage: llm-use <model-name>"
        llm-list
        return 1
    fi
    export LLM_MODEL="\$1"
    echo "Using model: \$LLM_MODEL"
}

llm-pull() {
    if [ -z "\$1" ]; then
        echo "Usage: llm-pull <model-name>"
        return 1
    fi
    ollama pull "\$1"
}
# <<< LLM Terminal Integration <<<
EOF
        print_success "LLM functions added to .bashrc"
    fi
else
    print_error ".zshrc not found"
    exit 1
fi

echo ""
echo "============================================"
print_success "LLM Terminal Integration Complete!"
echo "============================================"
echo ""
echo "Available commands:"
echo ""
echo "  📝 Quick Commands:"
echo "    llm \"your question\"          - Ask a quick question"
echo "    llm-chat                      - Start interactive chat session"
echo ""
echo "  🔧 Model Management:"
echo "    llm-list                      - List available models"
echo "    llm-use <model>               - Switch model for this session"
echo "    llm-pull <model>              - Download a new model"
echo "    llm-info                      - Show current model info"
echo ""
echo "  💻 Code Helpers:"
echo "    llm-explain <code/file>       - Explain code"
echo "    llm-review <file>             - Review code and suggest improvements"
echo ""
echo "  🌍 Utilities:"
echo "    llm-translate <text> <lang>   - Translate text"
echo ""
echo "Default model: $DEFAULT_MODEL"
echo ""
echo "Examples:"
echo "  llm \"What is Python?\""
echo "  llm-chat"
echo "  llm-explain script.py"
echo "  llm-use llama3.1:8b"
echo ""
echo "To use immediately:"
echo "  source ~/.zshrc  # (if using zsh)"
echo "  source ~/.bashrc  # (if using bash)"
echo ""
echo "Or close and reopen your terminal"

