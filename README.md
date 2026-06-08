# Ubuntu Development Environment Setup

Automated setup scripts for Ubuntu 24.04+ to configure a complete development environment for full-stack development, data science, machine learning, and physics research.

## Project Structure

```
ubuntu_for_devs/
├── scripts/                    # Setup scripts
│   ├── ubuntu_setup_*.sh       # Main setup scripts
│   └── utils/                   # Utility scripts
│       ├── add_llm_to_terminal.sh
│       ├── switch_llm_model.sh
│       ├── fix_zsh_default.sh
│       └── ubuntu_utilities.sh
├── docs/                        # Documentation
│   ├── TROUBLESHOOTING.md
│   ├── LLM_RECOMMENDATIONS.md
│   ├── LLM_TERMINAL_GUIDE.md
│   └── python_alternatives_guide.md
├── tests/                       # Test scripts
│   └── test_cuda.py
├── README.md                    # This file
├── LICENSE                      # MIT License
└── CONTRIBUTING.md              # Contribution guidelines
```

## Quick Start

1. **Make all scripts executable:**
   ```bash
   chmod +x scripts/*.sh scripts/utils/*.sh
   ```

2. **Run the interactive installer:**
   ```bash
   ./scripts/ubuntu_setup_all.sh
   ```

   Or run individual scripts as needed (see below).

## System Requirements

### Minimum Requirements
- **OS**: Ubuntu 24.04 LTS or newer
- **CPU**: 4+ cores recommended
- **RAM**: 8GB minimum, 16GB+ recommended
- **Storage**: 50GB+ free disk space (more for ML models and Docker images)
- **Network**: Internet connection for package downloads
- **Permissions**: sudo/administrator access

### Recommended Requirements
- **OS**: Ubuntu 24.04 LTS
- **CPU**: 8+ cores (e.g., Intel i7, AMD Ryzen 7)
- **RAM**: 16GB+ (32GB for ML workloads)
- **Storage**: 100GB+ SSD free space
- **GPU**: NVIDIA GPU with 6GB+ VRAM for ML/AI workloads (optional but recommended)
- **Network**: Stable broadband connection

### Tested Configuration
- **OS**: Ubuntu 24.04 LTS
- **CPU**: Intel Core i7-13620H (13th Gen, 16 cores)
- **RAM**: 32GB
- **GPU**: NVIDIA GeForce RTX 4060 Laptop GPU (8GB VRAM)
- **Storage**: SSD with 100GB+ free space

## Available Scripts

### Core Setup Scripts

#### 1. `ubuntu_setup_main.sh` ⭐ **Start Here**

The main setup script that installs essential packages and tools.

**What it installs:**
- Nala (faster apt alternative)
- Essential development packages (git, gcc, make, curl, wget, etc.)
- Docker and Docker Buildx (from official repository)
- Media codecs (ubuntu-restricted-extras)
- Gnome Tweaks and Extensions Manager
- Flatpak with Flathub repository
- Stacer system optimizer

**Usage:**
```bash
./scripts/ubuntu_setup_main.sh
```

**Note:** After completion, log out and back in for Docker group changes to take effect.

---

#### 2. `ubuntu_setup_terminal.sh` - Terminal Optimization

Installs and configures zsh with oh-my-zsh and useful plugins.

**What it installs:**
- Zsh shell
- Oh-my-zsh framework
- zsh-autosuggestions plugin
- zsh-syntax-highlighting plugin
- zsh-autocomplete plugin
- git-extras plugin
- Powerlevel10k theme
- Powerline fonts
- Useful aliases and configurations

**Usage:**
```bash
./scripts/ubuntu_setup_terminal.sh
```

**After installation:**
```bash
# Make zsh your default shell
chsh -s $(which zsh)
# Log out and back in for changes to take effect
```

---

#### 3. `ubuntu_setup_git.sh` - Git & GitHub Configuration

Configures Git and installs GitHub CLI.

**What it does:**
- Installs Git (if needed)
- Configures global user.name and user.email
- Installs GitHub CLI (gh)
- Optionally authenticates with GitHub

**Usage:**
```bash
./scripts/ubuntu_setup_git.sh
```

**Useful commands after setup:**
```bash
gh auth status              # Check authentication
gh repo create              # Create new repository
gh repo clone owner/repo    # Clone repository
```

---

### Development Environment Scripts

#### 4. `ubuntu_setup_python.sh` ⚠️ **USE WITH CAUTION**

Installs additional Python versions alongside the system Python.

**⚠️ WARNINGS:**
- This modifies system Python configuration
- Incorrect usage can break system tools
- **DO NOT RUN `sudo apt autoremove` after using this script**
- Only use if you understand Python alternatives system

**What it does:**
- Adds deadsnakes PPA
- Installs chosen Python version (3.9-3.13)
- Configures Python alternatives
- Protects gnome-terminal from breaking
- Installs pip for all Python versions
- Handles distutils for Python < 3.12

**Usage:**
```bash
./scripts/ubuntu_setup_python.sh
```

**After installation:**
```bash
# Switch between Python versions
sudo update-alternatives --config python3

# Create venv with specific version
python3.11 -m venv myenv
```

---

#### 5. `ubuntu_setup_fullstack.sh` - Full-Stack Development

Installs tools for web development.

**What it installs:**
- Node.js (via nvm - latest LTS)
- npm, yarn, pnpm
- PostgreSQL
- Redis
- MongoDB (optional)
- Docker Compose
- Additional development tools

**Usage:**
```bash
./scripts/ubuntu_setup_fullstack.sh
```

---

#### 6. `ubuntu_setup_datascience.sh` - Data Science Environment

Sets up a dedicated Conda environment for data science.

**What it installs:**
- Miniconda
- Conda environment (Python 3.12)
- Jupyter Notebook and Lab
- NumPy, Pandas, Matplotlib, Seaborn
- Scipy, Statsmodels
- Data visualization tools

**Usage:**
```bash
./scripts/ubuntu_setup_datascience.sh
```

**After installation:**
```bash
# Activate the environment
conda activate datascience

# Launch Jupyter
jupyter lab
```

---

#### 7. `ubuntu_setup_ml.sh` - Machine Learning Environment

Sets up a dedicated Conda environment for machine learning.

**What it installs:**
- Conda environment (Python 3.12)
- PyTorch (with CUDA support if GPU available)
- TensorFlow (with GPU support if available)
- Scikit-learn, XGBoost, LightGBM, CatBoost
- Transformers, Datasets, Accelerate
- MLflow, Weights & Biases, TensorBoard
- OpenCV, Pillow
- NLTK, SpaCy, Gensim

**Usage:**
```bash
./scripts/ubuntu_setup_ml.sh
```

**After installation:**
```bash
# Activate the environment
conda activate ml

# Test CUDA (if GPU available)
python test_cuda.py
```

---

#### 8. `ubuntu_setup_physics.sh` - Physics Research Environment

Sets up a dedicated Conda environment for physics research.

**What it installs:**
- Conda environment (Python 3.12)
- PHYSBO (Bayesian optimization)
- kafe2 (data analysis)
- Scikit-HEP (High Energy Physics)
- Scientific computing libraries

**Usage:**
```bash
./scripts/ubuntu_setup_physics.sh
```

**After installation:**
```bash
# Activate the environment
conda activate physics
```

---

### Optional Scripts

#### 9. `ubuntu_setup_ollama.sh` - Local LLMs

Installs Ollama for running local Large Language Models.

**What it does:**
- Installs Ollama
- Interactive model selection menu
- Optionally sets up Open WebUI (web interface)
- Creates launcher script for easy access
- Optionally adds convenient terminal commands (`llm`, `llm-chat`, etc.)

**Usage:**
```bash
./scripts/ubuntu_setup_ollama.sh
```

**After installation:**
```bash
# Basic Ollama commands
ollama run deepseek-r1:7b

# Or use convenient terminal commands (if integration enabled)
llm "What is machine learning?"
llm-chat  # Interactive session
llm-explain script.py  # Explain code
llm-review script.py  # Code review

# Start Web UI (if installed)
~/start-ollama-webui.sh
# Then open: http://localhost:8080
```

**Terminal Integration:**
After running the setup, you'll be prompted to add LLM commands to your terminal. Or install separately:
```bash
./scripts/utils/add_llm_to_terminal.sh
```

**See `LLM_RECOMMENDATIONS.md` for model selection guidance.**
**See `LLM_TERMINAL_GUIDE.md` for terminal integration usage.**

---

#### 10. `ubuntu_setup_claude.sh` - Claude Code + Skills

Installs the [Claude Code](https://claude.com/claude-code) CLI (if missing) and a
curated set of community skill/plugin marketplaces.

**What it does:**
- Installs the Claude Code CLI via the official installer (skips if already present)
- Adds and installs two native plugin marketplaces:
  - **academic-research-skills** ([Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills)) — research, writing, peer review, pipeline orchestration
  - **oh-my-claudecode / OMC** ([Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode)) — multi-agent orchestration, 28 agents, 32 skills
- Installs **Matt Pocock's skills** ([mattpocock/skills](https://github.com/mattpocock/skills)) by copying the SKILL.md directories into `~/.claude/skills/` (no Node.js required)

**Usage:**
```bash
./scripts/ubuntu_setup_claude.sh
```

**After installation:**
```bash
claude plugin list                 # List installed plugins
claude plugin marketplace list     # List marketplaces
claude plugin update <name>        # Update a plugin
# Run /setup-matt-pocock-skills inside Claude Code to configure those skills
```

> Restart any running Claude Code session for newly installed skills to load.

---

#### 11. `ubuntu_utilities.sh` - System Utilities Menu

Interactive menu with useful system maintenance commands.

**Features:**
- Check upgradable packages
- Find largest folders and files
- Display system information
- Check disk usage
- Launch htop/bpytop
- Clean package cache
- Fix VirtualBox errors
- Test Docker installation
- Show Git configuration

**Usage:**
```bash
chmod +x scripts/utils/ubuntu_utilities.sh
./scripts/utils/ubuntu_utilities.sh
```

---

## Recommended Installation Order

For a fresh Ubuntu installation:

### 1. Essential Setup
```bash
./scripts/ubuntu_setup_main.sh
```
Then **log out and back in** for Docker to work.

### 2. Terminal Enhancement
```bash
./scripts/ubuntu_setup_terminal.sh
chsh -s $(which zsh)
```
Then **log out and back in** again.

### 3. Development Tools
```bash
./scripts/ubuntu_setup_git.sh
```

### 4. Choose Your Stack

**For Full-Stack Development:**
```bash
./scripts/ubuntu_setup_fullstack.sh
```

**For Data Science:**
```bash
./scripts/ubuntu_setup_datascience.sh
```

**For Machine Learning:**
```bash
./scripts/ubuntu_setup_ml.sh
```

**For Physics Research:**
```bash
./scripts/ubuntu_setup_physics.sh
```

**For Multiple Stacks:**
You can install multiple environments - they use separate Conda environments.

### 5. Optional - Local AI
```bash
./scripts/ubuntu_setup_ollama.sh
```

### 6. Optional - Additional Python (⚠️ Advanced users only)
```bash
./scripts/ubuntu_setup_python.sh
```

---

## Using the Interactive Installer

The easiest way to set up everything:

```bash
./scripts/ubuntu_setup_all.sh
```

This provides an interactive menu with options:
- Quick Install (essential tools)
- Developer Install (full-stack + essential)
- Data Science Install (data science + ML + essential)
- Full Install (everything)
- Custom Install (choose what you need)

---

## Testing Your Setup

After running the main setup script:

```bash
# Test Docker
docker run hello-world

# Test Flatpak
flatpak search chrome

# Check installed packages
nala list --installed

# View system info
neofetch

# Test GPU (if NVIDIA)
nvidia-smi

# Test CUDA (if ML environment installed)
conda activate ml
python tests/test_cuda.py
```

---

## Documentation

- **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[docs/LLM_RECOMMENDATIONS.md](docs/LLM_RECOMMENDATIONS.md)** - Guide to selecting LLM models
- **[docs/LLM_TERMINAL_GUIDE.md](docs/LLM_TERMINAL_GUIDE.md)** - Using LLMs directly from terminal
- **[docs/python_alternatives_guide.md](docs/python_alternatives_guide.md)** - Python version management guide

---

## Troubleshooting

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for detailed solutions to common issues.

**Quick fixes:**
- **Docker permission denied**: `newgrp docker` or log out/in
- **Terminal not opening**: See TROUBLESHOOTING.md
- **apt_pkg error**: Usually cosmetic, see TROUBLESHOOTING.md
- **Python version conflicts**: `sudo update-alternatives --config python3`

---

## Notes

- All scripts are **idempotent** - safe to run multiple times
- Scripts will skip already-installed packages
- Backup files are created when modifying existing configurations
- Color-coded output: ✓ Green = Success, → Yellow = Info, ✗ Red = Error
- ML/AI packages are installed in dedicated Conda environments (not globally)

---

## Contributing

Feel free to modify these scripts for your needs. Each script is self-contained and well-commented.

**To contribute:**
1. Fork the repository
2. Make your changes
3. Test thoroughly
4. Submit a pull request

---

## License

These scripts are provided as-is for personal and educational use. Use at your own risk.

---

## Acknowledgments

Based on `after_install_ubuntu.md` with improvements for:
- Modularity and organization
- Error handling and user feedback
- Multiple development environments
- GPU support for ML workloads
- Local LLM integration

---

**Last Updated:** For Ubuntu 24.04 LTS

