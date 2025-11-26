#!/bin/bash

# Ubuntu Utilities Script
# Collection of useful system maintenance and information commands

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}${1}${NC}"
}

show_menu() {
    clear
    echo "============================================"
    echo "Ubuntu Utilities"
    echo "============================================"
    echo ""
    echo "1)  Check upgradable packages"
    echo "2)  Show largest folders in current directory (top 5)"
    echo "3)  Show largest folders including subdirectories (top 5)"
    echo "4)  Find largest files in a specific directory"
    echo "5)  Display system information"
    echo "6)  Check disk usage"
    echo "7)  Show running processes (htop)"
    echo "8)  Show system resources (bpytop)"
    echo "9)  Clean package cache"
    echo "10) Fix VirtualBox RTR3InitEx error"
    echo "11) Test Docker installation"
    echo "12) Show Git configuration"
    echo "13) Exit"
    echo ""
}

check_upgradable() {
    print_header "=== Upgradable Packages ==="
    apt list --upgradable
    echo ""
    read -p "Press Enter to continue..."
}

largest_folders_current() {
    print_header "=== Largest 5 Folders in Current Directory ==="
    du -hs * 2>/dev/null | sort -rh | head -5
    echo ""
    read -p "Press Enter to continue..."
}

largest_folders_recursive() {
    print_header "=== Largest 5 Folders Including Subdirectories ==="
    du -Sh * 2>/dev/null | sort -rh | head -5
    echo ""
    read -p "Press Enter to continue..."
}

find_largest_files() {
    print_header "=== Find Largest Files ==="
    read -p "Enter the directory path to search: " DIR_PATH
    if [ -d "$DIR_PATH" ]; then
        echo "Searching for largest 5 files in $DIR_PATH..."
        find "$DIR_PATH" -type f -exec du -Sh {} + 2>/dev/null | sort -rh | head -n 5
    else
        echo "Directory not found: $DIR_PATH"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

system_info() {
    print_header "=== System Information ==="
    if command -v neofetch &> /dev/null; then
        neofetch
    else
        echo "OS: $(lsb_release -d | cut -f2)"
        echo "Kernel: $(uname -r)"
        echo "Architecture: $(uname -m)"
        echo "Hostname: $(hostname)"
        echo "Uptime: $(uptime -p)"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

disk_usage() {
    print_header "=== Disk Usage ==="
    df -h
    echo ""
    read -p "Press Enter to continue..."
}

show_htop() {
    if command -v htop &> /dev/null; then
        htop
    else
        echo "htop not installed. Install with: sudo apt install htop"
        read -p "Press Enter to continue..."
    fi
}

show_bpytop() {
    if command -v bpytop &> /dev/null; then
        bpytop
    else
        echo "bpytop not installed. Install with: sudo apt install bpytop"
        read -p "Press Enter to continue..."
    fi
}

clean_cache() {
    print_header "=== Cleaning Package Cache ==="
    echo "This will clean apt/nala cache and remove unnecessary packages"
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v nala &> /dev/null; then
            sudo nala clean
            sudo nala autopurge
        else
            sudo apt clean
            sudo apt autoclean
            echo ""
            echo "⚠️  To remove unused packages, you can run: sudo apt autoremove"
            echo "    (But be careful if you've installed additional Python versions!)"
        fi
        echo "Cache cleaned!"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

fix_virtualbox() {
    print_header "=== Fix VirtualBox RTR3InitEx Error ==="
    echo "This will fix the VirtualBox RTR3InitEx failed with rc=-1912 error"
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Checking for virtualbox-dkms..."
        if dpkg -l | grep -q virtualbox-dkms; then
            echo "Removing virtualbox-dkms and installing dkms..."
            sudo apt-get purge -y virtualbox-dkms
            sudo apt-get install -y dkms
        fi
        echo "Rebuilding VirtualBox kernel modules..."
        sudo /sbin/vboxconfig
        echo "Done!"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

test_docker() {
    print_header "=== Test Docker Installation ==="
    if command -v docker &> /dev/null; then
        echo "Docker version:"
        docker --version
        echo ""
        echo "Running hello-world container..."
        docker run hello-world
    else
        echo "Docker is not installed"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

show_git_config() {
    print_header "=== Git Configuration ==="
    if command -v git &> /dev/null; then
        git config --global -l
    else
        echo "Git is not installed"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    read -p "Enter choice [1-13]: " choice
    case $choice in
        1) check_upgradable ;;
        2) largest_folders_current ;;
        3) largest_folders_recursive ;;
        4) find_largest_files ;;
        5) system_info ;;
        6) disk_usage ;;
        7) show_htop ;;
        8) show_bpytop ;;
        9) clean_cache ;;
        10) fix_virtualbox ;;
        11) test_docker ;;
        12) show_git_config ;;
        13) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option. Press Enter to continue..."; read ;;
    esac
done
