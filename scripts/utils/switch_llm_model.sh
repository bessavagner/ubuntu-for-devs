#!/bin/bash

# Quick script to switch default LLM model
# Usage: ./scripts/utils/switch_llm_model.sh <model-name>

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
echo "Switch Default LLM Model"
echo "============================================"
echo ""

# Check if model name provided
if [ -z "$1" ]; then
    print_info "Available models:"
    ollama list 2>/dev/null | tail -n +2 | awk '{print "  - " $1}' || echo "  (No models found)"
    echo ""
    echo "Usage: $0 <model-name>"
    echo "Example: $0 codellama:7b"
    echo "Example: $0 deepseek-r1:7b"
    exit 1
fi

MODEL_NAME="$1"

# Verify model exists
if ! ollama list 2>/dev/null | grep -q "^$MODEL_NAME "; then
    print_error "Model '$MODEL_NAME' not found"
    echo ""
    print_info "Available models:"
    ollama list 2>/dev/null | tail -n +2 | awk '{print "  - " $1}'
    echo ""
    echo "To download a model: ollama pull $MODEL_NAME"
    exit 1
fi

print_success "Model found: $MODEL_NAME"

# Update .zshrc
if [ -f "$HOME/.zshrc" ]; then
    if grep -q "export DEFAULT_LLM_MODEL=" "$HOME/.zshrc"; then
        # Replace existing default
        sed -i "s|export DEFAULT_LLM_MODEL=.*|export DEFAULT_LLM_MODEL=\"$MODEL_NAME\"|" "$HOME/.zshrc"
        print_success "Updated default model in ~/.zshrc"
    else
        # Add if not present
        sed -i '/# >>> LLM Terminal Integration >>>/a export DEFAULT_LLM_MODEL="'$MODEL_NAME'"' "$HOME/.zshrc"
        print_success "Added default model to ~/.zshrc"
    fi
fi

# Update .bashrc
if [ -f "$HOME/.bashrc" ]; then
    if grep -q "export DEFAULT_LLM_MODEL=" "$HOME/.bashrc"; then
        sed -i "s|export DEFAULT_LLM_MODEL=.*|export DEFAULT_LLM_MODEL=\"$MODEL_NAME\"|" "$HOME/.bashrc"
        print_success "Updated default model in ~/.bashrc"
    else
        sed -i '/# >>> LLM Terminal Integration >>>/a export DEFAULT_LLM_MODEL="'$MODEL_NAME'"' "$HOME/.bashrc"
        print_success "Added default model to ~/.bashrc"
    fi
fi

echo ""
echo "============================================"
print_success "Default model changed to: $MODEL_NAME"
echo "============================================"
echo ""
echo "To use immediately:"
echo "  source ~/.zshrc  # (if using zsh)"
echo "  source ~/.bashrc  # (if using bash)"
echo ""
echo "Or close and reopen your terminal"
echo ""
echo "Now you can use:"
echo "  llm 'your question'     # Uses $MODEL_NAME"
echo "  llm-chat                 # Interactive chat with $MODEL_NAME"

