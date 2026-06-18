#!/bin/bash

# Ubuntu Setup - Master Installer
# Interactive menu to run all setup scripts

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_header() {
    echo -e "${BLUE}${BOLD}$1${NC}"
}

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
    echo -e "${RED}${BOLD}⚠️  $1${NC}"
}

show_main_menu() {
    clear
    echo "============================================"
    echo "  Ubuntu Post-Installation Setup"
    echo "============================================"
    echo ""
    echo "Choose installation options:"
    echo ""
    echo "  1) Quick Install (Essential packages only)"
    echo "  2) Developer Install (Essential + Terminal + Git + Fullstack)"
    echo "  3) Data Science Install (Essential + Data Science + ML tools)"
    echo "  4) Full Install (Everything except Python versions)"
    echo "  5) Custom Install (Choose components)"
    echo ""
    echo "  6) Run individual scripts"
    echo "  7) Open system utilities"
    echo ""
    echo "  9) View README"
    echo "  0) Exit"
    echo ""
}

show_individual_menu() {
    clear
    echo "============================================"
    echo "  Individual Script Installation"
    echo "============================================"
    echo ""
    echo "Essential:"
    echo "  1) Main Setup (Essential packages)"
    echo "  2) Terminal Optimization (zsh, oh-my-zsh)"
    echo "  3) Git & GitHub Configuration"
    echo ""
    echo "Development:"
    echo "  4) Fullstack Development (Node.js, databases, Docker Compose)"
    echo ""
    echo "Data Science & ML:"
    echo "  5) Data Science (Jupyter, Conda, libraries)"
    echo "  6) Machine Learning (TensorFlow, PyTorch, CUDA)"
    echo ""
    echo "Scientific Computing:"
    echo "  7) Physics & Scientific Computing (LaTeX, tools)"
    echo ""
    echo "Optional:"
    echo "  8) Ollama (Local LLMs)"
    echo "  9) Additional Python Versions ⚠️  CAUTION"
    echo " 10) Claude Code + Skills (academic-research, OMC, mattpocock)"
    echo ""
    echo "  0) Back to main menu"
    echo ""
}

show_custom_menu() {
    clear
    echo "============================================"
    echo "  Custom Installation"
    echo "============================================"
    echo ""
    echo "Select components to install (y/n):"
    echo ""
}

run_script() {
    local script="$1"
    local name="$2"

    if [ ! -f "$SCRIPT_DIR/$script" ]; then
        print_error "Script not found: $script"
        return 1
    fi

    print_header "=== Running: $name ==="
    echo ""

    if bash "$SCRIPT_DIR/$script"; then
        print_success "$name completed successfully"
        return 0
    else
        print_error "$name failed"
        return 1
    fi
}

quick_install() {
    print_header "=== Quick Install ==="
    echo "This will install essential packages only"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_script "ubuntu_setup_main.sh" "Main Setup"
        echo ""
        print_success "Quick install completed!"
        print_info "Remember to log out and back in for Docker to work"
    fi
}

developer_install() {
    print_header "=== Developer Install ==="
    echo "This will install:"
    echo "  - Essential packages"
    echo "  - Terminal optimization (zsh)"
    echo "  - Git & GitHub CLI"
    echo "  - Fullstack development tools (Node.js, databases, Docker Compose)"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_script "ubuntu_setup_main.sh" "Main Setup"
        echo ""
        read -p "Press Enter to continue to Terminal Setup..."
        run_script "ubuntu_setup_terminal.sh" "Terminal Optimization"
        echo ""
        read -p "Press Enter to continue to Git Setup..."
        run_script "ubuntu_setup_git.sh" "Git & GitHub Configuration"
        echo ""
        read -p "Press Enter to continue to Fullstack Setup..."
        run_script "ubuntu_setup_fullstack.sh" "Fullstack Development"
        echo ""
        print_success "Developer install completed!"
        print_info "Log out and back in, then run: chsh -s \$(which zsh)"
    fi
}

datascience_install() {
    print_header "=== Data Science Install ==="
    echo "This will install:"
    echo "  - Essential packages"
    echo "  - Data Science tools (Jupyter, Conda, libraries)"
    echo "  - Machine Learning (TensorFlow, PyTorch, CUDA if GPU available)"
    echo ""
    print_warning "This requires conda to be installed first"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_script "ubuntu_setup_main.sh" "Main Setup"
        echo ""
        read -p "Press Enter to continue to Data Science Setup..."
        run_script "ubuntu_setup_datascience.sh" "Data Science Environment"
        echo ""
        read -p "Press Enter to continue to ML Setup..."
        run_script "ubuntu_setup_ml.sh" "Machine Learning"
        echo ""
        print_success "Data Science install completed!"
    fi
}

full_install() {
    print_header "=== Full Install ==="
    echo "This will install:"
    echo "  - Essential packages"
    echo "  - Terminal optimization"
    echo "  - Git & GitHub CLI"
    echo "  - Fullstack development tools"
    echo "  - Data Science tools"
    echo "  - Machine Learning tools"
    echo "  - Physics & Scientific computing"
    echo "  - Ollama with DeepSeek"
    echo ""
    print_warning "This will download several GB of data (especially Ollama models and LaTeX)"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_script "ubuntu_setup_main.sh" "Main Setup"
        echo ""
        read -p "Press Enter to continue to Terminal Setup..."
        run_script "ubuntu_setup_terminal.sh" "Terminal Optimization"
        echo ""
        read -p "Press Enter to continue to Git Setup..."
        run_script "ubuntu_setup_git.sh" "Git & GitHub Configuration"
        echo ""
        read -p "Press Enter to continue to Fullstack Setup..."
        run_script "ubuntu_setup_fullstack.sh" "Fullstack Development"
        echo ""
        read -p "Press Enter to continue to Data Science Setup..."
        run_script "ubuntu_setup_datascience.sh" "Data Science Environment"
        echo ""
        read -p "Press Enter to continue to ML Setup..."
        run_script "ubuntu_setup_ml.sh" "Machine Learning"
        echo ""
        read -p "Press Enter to continue to Physics Setup..."
        run_script "ubuntu_setup_physics.sh" "Physics & Scientific Computing"
        echo ""
        read -p "Press Enter to continue to Ollama Setup..."
        run_script "ubuntu_setup_ollama.sh" "Ollama Setup"
        echo ""
        print_success "Full install completed!"
    fi
}

custom_install() {
    show_custom_menu

    read -p "Main Setup (essential packages)? (y/n) " -n 1 MAIN
    echo ""
    read -p "Terminal Optimization (zsh)? (y/n) " -n 1 TERM
    echo ""
    read -p "Git & GitHub? (y/n) " -n 1 GIT
    echo ""
    read -p "Fullstack Development (Node.js, databases)? (y/n) " -n 1 FULLSTACK
    echo ""
    read -p "Data Science (Jupyter, Conda)? (y/n) " -n 1 DATA
    echo ""
    read -p "Machine Learning (TensorFlow, PyTorch)? (y/n) " -n 1 ML
    echo ""
    read -p "Physics & Scientific Computing (LaTeX)? (y/n) " -n 1 PHYSICS
    echo ""
    read -p "Ollama (Local LLMs)? (y/n) " -n 1 OLLAMA
    echo ""
    read -p "Additional Python versions? ⚠️  (y/n) " -n 1 PYTHON
    echo ""
    read -p "Claude Code + Skills? (y/n) " -n 1 CLAUDE
    echo ""

    echo ""
    echo "Starting custom installation..."
    echo ""

    [[ $MAIN =~ ^[Yy]$ ]] && run_script "ubuntu_setup_main.sh" "Main Setup" && echo ""
    [[ $TERM =~ ^[Yy]$ ]] && run_script "ubuntu_setup_terminal.sh" "Terminal Optimization" && echo ""
    [[ $GIT =~ ^[Yy]$ ]] && run_script "ubuntu_setup_git.sh" "Git & GitHub" && echo ""
    [[ $FULLSTACK =~ ^[Yy]$ ]] && run_script "ubuntu_setup_fullstack.sh" "Fullstack Development" && echo ""
    [[ $DATA =~ ^[Yy]$ ]] && run_script "ubuntu_setup_datascience.sh" "Data Science" && echo ""
    [[ $ML =~ ^[Yy]$ ]] && run_script "ubuntu_setup_ml.sh" "Machine Learning" && echo ""
    [[ $PHYSICS =~ ^[Yy]$ ]] && run_script "ubuntu_setup_physics.sh" "Physics & Scientific Computing" && echo ""
    [[ $OLLAMA =~ ^[Yy]$ ]] && run_script "ubuntu_setup_ollama.sh" "Ollama Setup" && echo ""
    [[ $PYTHON =~ ^[Yy]$ ]] && run_script "ubuntu_setup_python.sh" "Python Setup" && echo ""
    [[ $CLAUDE =~ ^[Yy]$ ]] && run_script "ubuntu_setup_claude.sh" "Claude Code + Skills" && echo ""

    print_success "Custom install completed!"
}

individual_scripts() {
    while true; do
        show_individual_menu
        read -p "Enter choice: " choice
        case $choice in
            1) run_script "ubuntu_setup_main.sh" "Main Setup" ;;
            2) run_script "ubuntu_setup_terminal.sh" "Terminal Optimization" ;;
            3) run_script "ubuntu_setup_git.sh" "Git & GitHub" ;;
            4) run_script "ubuntu_setup_fullstack.sh" "Fullstack Development" ;;
            5) run_script "ubuntu_setup_datascience.sh" "Data Science" ;;
            6) run_script "ubuntu_setup_ml.sh" "Machine Learning" ;;
            7) run_script "ubuntu_setup_physics.sh" "Physics & Scientific Computing" ;;
            8) run_script "ubuntu_setup_ollama.sh" "Ollama Setup" ;;
            9) run_script "ubuntu_setup_python.sh" "Python Setup" ;;
            10) run_script "ubuntu_setup_claude.sh" "Claude Code + Skills" ;;
            0) break ;;
            *) print_error "Invalid option" ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
    done
}

show_readme() {
    if [ -f "$SCRIPT_DIR/UBUNTU_SETUP_README.md" ]; then
        if command -v less &> /dev/null; then
            less "$SCRIPT_DIR/UBUNTU_SETUP_README.md"
        else
            cat "$SCRIPT_DIR/UBUNTU_SETUP_README.md"
            echo ""
            read -p "Press Enter to continue..."
        fi
    else
        print_error "README not found"
        read -p "Press Enter to continue..."
    fi
}

# Main loop
while true; do
    show_main_menu
    read -p "Enter choice: " choice
    case $choice in
        1) quick_install ;;
        2) developer_install ;;
        3) datascience_install ;;
        4) full_install ;;
        5) custom_install ;;
        6) individual_scripts ;;
        7) [ -f "$SCRIPT_DIR/ubuntu_utilities.sh" ] && bash "$SCRIPT_DIR/ubuntu_utilities.sh" ;;
        9) show_readme ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) print_error "Invalid option" ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
done
