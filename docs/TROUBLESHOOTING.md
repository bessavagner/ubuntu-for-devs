# Troubleshooting Guide

Common issues and solutions for Ubuntu development setup scripts.

## Table of Contents

- [Docker Issues](#docker-issues)
- [Terminal Issues](#terminal-issues)
- [Python Issues](#python-issues)
- [apt_pkg Module Error](#apt_pkg-module-error)
- [Package Installation Errors](#package-installation-errors)
- [Git and GitHub Issues](#git-and-github-issues)
- [Ollama and LLM Issues](#ollama-and-llm-issues)
- [Permission Issues](#permission-issues)
- [Conda Issues](#conda-issues)
- [System Configuration](#system-configuration)

---

## Docker Issues

### Docker Permission Denied

**Error:**
```
permission denied while trying to connect to the Docker daemon socket
```

**Solution:**
```bash
# Log out and back in for group changes to take effect
# Or run:
newgrp docker

# Verify you're in the docker group
groups | grep docker
```

If still not working:
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

### Docker Service Not Running

**Error:**
```
Cannot connect to the Docker daemon
```

**Solution:**
```bash
# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Check status
sudo systemctl status docker
```

### Docker Installation 404 Error

**Error:**
```
Error: Client error '404 Not Found' for url 'http://security.ubuntu.com/...'
```

**Solution:**
The setup script uses Docker's official repository. If you still get errors:
```bash
# Remove old Docker installation
sudo apt remove docker.io docker-buildx

# Re-run the setup script
./ubuntu_setup_main.sh
```

---

## Terminal Issues

### Terminal Not Opening (Ctrl+Alt+T)

**Error:**
```
gnome-terminal: cannot execute: required file not found
```

**Cause:** The `gnome-terminal` shebang points to a Python version that doesn't exist.

**Solution:**
```bash
# Find available Python
ls -la /usr/bin/python3*

# Fix the shebang (replace 3.12 with your system Python version)
sudo sed -i '1s|.*|#!/usr/bin/python3.12|' /usr/bin/gnome-terminal

# Verify
head -1 /usr/bin/gnome-terminal
```

### Terminal Doesn't Show Changes After zsh Installation

**Solution:**
```bash
# Make zsh your default shell
chsh -s $(which zsh)

# Log out and back in completely
# Or restart your terminal session
```

### zsh Not Starting as Default Shell

**Problem:** Default shell is set to zsh, but terminal still opens with bash.

**Solution:**
1. **Close ALL terminal windows completely** (not just tabs)
2. **Open a NEW terminal window** (Ctrl+Alt+T)
3. **OR log out and log back in**

**Verify:**
```bash
# Check default shell
getent passwd $USER | cut -d: -f7

# Should show: /usr/bin/zsh or /bin/zsh
# If it shows bash, run:
chsh -s $(which zsh)
```

**If still not working:**
```bash
# Check if gnome-terminal has a custom command set
gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ custom-command

# If it shows something other than '', remove it:
DEFAULT_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${DEFAULT_PROFILE}/ custom-command ''
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${DEFAULT_PROFILE}/ use-custom-command false
```

### Oh-my-zsh Not Loading

**Solution:**
```bash
# Check if .zshrc exists
ls -la ~/.zshrc

# If missing, reinstall oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Or copy the template
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
```

### Sourcing .zshrc from bash

**Error:**
```
bash: ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh: bad substitution
Error: Oh My Zsh can't be loaded from: bash.
```

**Cause:** You're trying to source a zsh configuration file (`~/.zshrc`) from bash.

**Solution:**
- **Don't source .zshrc from bash** - it's a zsh-specific file
- **Switch to zsh first:**
  ```bash
  zsh
  # Then you can use zsh commands
  ```
- **Or reload bash config:**
  ```bash
  source ~/.bashrc
  ```

---

## Python Issues

### apt_pkg Module Error

**Error:**
```
ModuleNotFoundError: No module named 'apt_pkg'
E: Problem executing scripts APT::Update::Post-Invoke
```

**Cause:** Python version mismatch between system Python and the `cnf-update-db` hook.

**Solution 1: Fix the hook (Recommended)**
```bash
# Check which Python the hook uses
head -1 /usr/lib/cnf-update-db

# Fix to use system Python (replace 3.12 with your system Python)
sudo sed -i '1s|.*|#!/usr/bin/python3.12|' /usr/lib/cnf-update-db

# Verify it works
/usr/bin/python3.12 -c "import apt_pkg; print('OK')"
```

**Solution 2: Disable the hook (Workaround)**
```bash
# Disable the problematic hook
sudo mv /usr/lib/cnf-update-db /usr/lib/cnf-update-db.disabled

# This is safe - it only affects command-not-found suggestions
```

**Solution 3: Reinstall python3-apt**
```bash
# Try to reinstall (may fail if there are dependency conflicts)
sudo apt remove --purge python3-apt
sudo apt install python3-apt
```

**Note:** This error is usually cosmetic and doesn't affect `apt` functionality. The hook is only used for command-not-found suggestions.

### Python Version Conflicts

**Error:** System tools break after installing additional Python versions.

**Solution:**
```bash
# Switch back to system Python
sudo update-alternatives --config python3
# Select the system Python version (usually /usr/bin/python3.12)

# Check current Python
python3 --version
which python3
```

### pip Not Found

**Solution:**
```bash
# Install pip for your Python version
python3 -m ensurepip --upgrade

# Or use get-pip.py
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
python3 /tmp/get-pip.py
```

### Virtual Environment Issues

**Error:** `python3-venv` not found

**Solution:**
```bash
# Install venv module
sudo apt install python3-venv

# Create virtual environment
python3 -m venv myenv
source myenv/bin/activate
```

---

## Conda Issues

### Conda Base Environment Auto-Activating

**Problem:** Conda base environment activates automatically when opening terminal.

**Solution:**
```bash
# Disable auto-activation
conda config --set auto_activate_base false

# Reload shell configuration
source ~/.zshrc  # if using zsh
# OR
source ~/.bashrc  # if using bash

# Or close and reopen terminal
```

**Verify:**
```bash
conda config --show auto_activate_base
# Should show: auto_activate: False
```

### Conda Command Not Found

**Error:**
```
conda: command not found
```

**Solution:**
```bash
# Add conda to PATH
export PATH="$HOME/miniconda3/bin:$PATH"

# Or for Anaconda
export PATH="$HOME/anaconda3/bin:$PATH"

# Make it permanent - add to ~/.zshrc or ~/.bashrc
echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.zshrc
```

### Conda Environment Not Activating

**Error:**
```
CommandNotFoundError: Your shell has not been properly configured to use 'conda activate'.
```

**Solution:**
```bash
# Initialize conda for your shell
conda init zsh  # if using zsh
# OR
conda init bash  # if using bash

# Then reload shell
source ~/.zshrc  # or ~/.bashrc
```

---

## Package Installation Errors

### Unable to Locate Package

**Error:**
```
E: Unable to locate package <package-name>
```

**Solution:**
```bash
# Update package lists
sudo apt update

# If using nala
sudo nala update

# Check if package exists
apt search <package-name>
```

### Broken Dependencies

**Error:**
```
The following packages have unmet dependencies
```

**Solution:**
```bash
# Fix broken dependencies
sudo apt --fix-broken install

# Clean package cache
sudo apt clean
sudo apt autoclean

# Update and upgrade
sudo apt update
sudo apt upgrade
```

### GPG Key Errors

**Error:**
```
W: GPG error: ... NO_PUBKEY <key-id>
```

**Solution:**
```bash
# Import the missing key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys <key-id>

# Or update keys
sudo apt update 2>&1 | grep NO_PUBKEY | sed 's/.*NO_PUBKEY //' | xargs -I {} sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys {}
```

---

## Git and GitHub Issues

### GitHub CLI Authentication Failed

**Error:**
```
gh: authentication required
```

**Solution:**
```bash
# Authenticate with GitHub
gh auth login

# Check authentication status
gh auth status

# If token expired, re-authenticate
gh auth refresh
```

### Git Configuration Missing

**Solution:**
```bash
# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify
git config --list
```

---

## Ollama and LLM Issues

### Ollama Not Starting

**Error:**
```
ollama: command not found
```

**Solution:**
```bash
# Reinstall Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Or check if it's in PATH
which ollama

# Add to PATH if needed
export PATH=$PATH:$HOME/.local/bin
```

### Model Download Fails

**Error:**
```
Error: failed to pull model
```

**Solution:**
```bash
# Check internet connection
ping -c 3 ollama.com

# Check disk space
df -h

# Try pulling again
ollama pull <model-name>

# Check Ollama service
systemctl --user status ollama
```

### Out of Memory (OOM) Errors

**Error:**
```
CUDA out of memory
```

**Solution:**
```bash
# Check GPU memory
nvidia-smi

# Use smaller models (7B instead of 13B)
ollama pull llama3.1:8b  # Instead of llama3.1:13b

# Close other GPU applications
# Monitor VRAM usage
watch -n 1 nvidia-smi
```

### Model Not Found

**Error:**
```
Error: model '<name>' not found
```

**Solution:**
```bash
# List available models
ollama list

# Search for correct model name
# Check: https://ollama.com/library

# Pull with correct name
ollama pull llama3.1:8b  # Note the colon and version
```

---

## Permission Issues

### Permission Denied on Scripts

**Error:**
```
Permission denied: ./script.sh
```

**Solution:**
```bash
# Make script executable
chmod +x script.sh

# Run it
./script.sh
```

### Sudo Password Prompts

**Solution:**
```bash
# If you want passwordless sudo (not recommended for security)
# Edit sudoers file
sudo visudo

# Add line (replace USERNAME):
USERNAME ALL=(ALL) NOPASSWD: ALL
```

### File Ownership Issues

**Solution:**
```bash
# Change ownership
sudo chown -R $USER:$USER ~/directory

# Fix permissions
chmod -R 755 ~/directory
```

---

## System Configuration

### Flatpak Applications Not Showing

**Solution:**
```bash
# Restart session or reboot
# Then check available apps
flatpak search <app-name>

# List installed apps
flatpak list
```

### GNOME Extensions Not Working

**Solution:**
```bash
# Install Extension Manager (if not installed)
sudo apt install gnome-shell-extension-manager

# Launch it
gnome-shell-extension-manager

# Enable extensions
gnome-extensions enable <extension-id>
```

### Keyboard Shortcuts Not Working

**Solution:**
```bash
# Open Settings
gnome-control-center keyboard

# Or use gsettings
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal '<Primary><Alt>t'

# Check current shortcuts
gsettings list-recursively | grep keyboard
```

### System Not Recognizing New Packages

**Solution:**
```bash
# Update package database
sudo apt update

# Refresh system paths
hash -r

# Log out and back in
```

---

## General Debugging Tips

### Check Logs

```bash
# System logs
journalctl -xe

# Service logs
sudo systemctl status <service-name>

# Application logs
tail -f ~/.local/share/<app>/logs/*.log
```

### Verify Installations

```bash
# Check if command exists
which <command>
command -v <command>

# Check version
<command> --version

# Check if service is running
systemctl status <service>
```

### Reset Configuration

```bash
# Backup current config
cp ~/.config/file ~/.config/file.backup

# Remove config
rm ~/.config/file

# Re-run setup script
./ubuntu_setup_<component>.sh
```

---

## Getting Help

If you encounter issues not covered here:

1. **Check script output** - Scripts provide color-coded messages:
   - ✓ Green = Success
   - → Yellow = Info
   - ✗ Red = Error

2. **Review logs** - Check terminal output for specific error messages

3. **Verify system requirements** - Ensure you meet minimum requirements

4. **Check Ubuntu version** - Scripts are tested on Ubuntu 24.04+

5. **Search error messages** - Many errors have solutions on Ask Ubuntu or Stack Overflow

---

## Contributing Fixes

If you find a solution to a problem not listed here, please contribute:

1. Document the error message
2. Document the solution
3. Add it to this troubleshooting guide
4. Submit a pull request

---

## Quick Reference

| Issue | Quick Fix |
|-------|-----------|
| Docker permission denied | `newgrp docker` or log out/in |
| Terminal not opening | Fix shebang: `sudo sed -i '1s\|.*\|#!/usr/bin/python3.12\|' /usr/bin/gnome-terminal` |
| zsh not default | `chsh -s $(which zsh)` then close all terminals |
| apt_pkg error | Fix hook: `sudo sed -i '1s\|.*\|#!/usr/bin/python3.12\|' /usr/lib/cnf-update-db` |
| Conda auto-activating | `conda config --set auto_activate_base false` |
| Python version conflict | `sudo update-alternatives --config python3` |
| Package not found | `sudo apt update` |
| Broken dependencies | `sudo apt --fix-broken install` |
| Script permission denied | `chmod +x script.sh` |
| Ollama not found | Reinstall: `curl -fsSL https://ollama.com/install.sh \| sh` |

---

**Last Updated:** Based on Ubuntu 24.04 LTS
