#!/bin/bash

# Data Science Setup Script
# Installs JupyterLab, Conda, and essential data science libraries

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
echo "Data Science Environment Setup"
echo "============================================"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root (don't use sudo)"
   exit 1
fi

# Install Miniconda
print_info "Setting up Miniconda (lightweight conda distribution)..."
if [ ! -d "$HOME/miniconda3" ] && [ ! -d "$HOME/anaconda3" ]; then
    print_info "Downloading Miniconda installer..."
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    INSTALLER_PATH="/tmp/miniconda_installer.sh"
    
    curl -fsSL "$MINICONDA_URL" -o "$INSTALLER_PATH"
    
    print_info "Installing Miniconda (this may take a few minutes)..."
    bash "$INSTALLER_PATH" -b -p "$HOME/miniconda3"
    rm "$INSTALLER_PATH"
    
    # Initialize conda for bash and zsh
    "$HOME/miniconda3/bin/conda" init bash
    "$HOME/miniconda3/bin/conda" init zsh
    
    # Disable auto-activation of base environment
    "$HOME/miniconda3/bin/conda" config --set auto_activate_base false
    
    # Add conda to PATH for current session
    export PATH="$HOME/miniconda3/bin:$PATH"
    
    print_success "Miniconda installed"
else
    print_success "Conda already installed (Miniconda or Anaconda)"
    # Add conda to PATH if not already there
    if [ -d "$HOME/miniconda3" ]; then
        export PATH="$HOME/miniconda3/bin:$PATH"
    elif [ -d "$HOME/anaconda3" ]; then
        export PATH="$HOME/anaconda3/bin:$PATH"
    fi
fi

# Verify conda is available
if command_exists conda; then
    CONDA_VERSION=$(conda --version)
    print_success "Conda available: $CONDA_VERSION"
    
    # Disable auto-activation of base environment (if not already set)
    print_info "Disabling conda base environment auto-activation..."
    conda config --set auto_activate_base false 2>/dev/null || true
    print_success "Conda base auto-activation disabled"
else
    print_error "Conda installation failed or not in PATH"
    exit 1
fi

# Accept Terms of Service for the default Anaconda channels.
# Newer conda (24.x+) refuses to operate on the default channels until their
# ToS are accepted, raising CondaToSNonInteractiveError. The `conda tos`
# subcommand only exists on these newer versions, so guard for it.
if conda tos --help >/dev/null 2>&1; then
    print_info "Accepting Terms of Service for default conda channels..."
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true
    print_success "Conda channel Terms of Service accepted"
fi

# Update conda
print_info "Updating conda..."
conda update -n base -c defaults conda -y -q
print_success "Conda updated"

# Create data science environment
echo ""
print_info "Creating 'datascience' conda environment with Python 3.12..."
if conda env list | grep -q "^datascience "; then
    print_success "Environment 'datascience' already exists"
    read -p "Do you want to recreate it? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        conda env remove -n datascience -y
        conda create -n datascience python=3.12 -y -q
        print_success "Environment 'datascience' recreated"
    fi
else
    conda create -n datascience python=3.12 -y -q
    print_success "Environment 'datascience' created"
fi

# Activate environment and install packages
print_info "Installing data science packages..."
eval "$(conda shell.bash hook)"
conda activate datascience

# Install essential data science packages
print_info "Installing core data science libraries..."
pip install --quiet --upgrade pip

# Core scientific computing
pip install --quiet numpy scipy pandas matplotlib seaborn

# JupyterLab and notebook
pip install --quiet jupyterlab jupyter notebook ipykernel

# Advanced visualization
pip install --quiet plotly bokeh altair

# Machine learning basics
pip install --quiet scikit-learn

# Statistical analysis
pip install --quiet statsmodels pingouin

# Data manipulation and I/O
pip install --quiet openpyxl xlrd pyarrow h5py

# Image processing
pip install --quiet pillow opencv-python-headless

# Progress bars and utilities
pip install --quiet tqdm ipywidgets

print_success "Data science packages installed"

# Register environment as Jupyter kernel
print_info "Registering conda environment as Jupyter kernel..."
python -m ipykernel install --user --name datascience --display-name "Python (Data Science)"
print_success "Kernel registered"

# Install JupyterLab extensions
print_info "Installing JupyterLab extensions..."
jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build 2>/dev/null || true
jupyter labextension install plotlywidget --no-build 2>/dev/null || true

# Optional: Install R language
echo ""
read -p "Do you want to install R language for statistical analysis? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Setting up R language..."
    
    # Add CRAN repository
    sudo apt update
    sudo apt install -y r-base r-base-dev
    
    # Install IRkernel for Jupyter
    print_info "Installing IRkernel (R kernel for Jupyter)..."
    R --slave -e "install.packages(c('IRkernel', 'devtools'), repos='https://cloud.r-project.org')" || true
    R --slave -e "IRkernel::installspec(user = TRUE)" || true
    
    print_success "R language installed"
    print_info "You can use R in Jupyter notebooks with the R kernel"
fi

# Optional: Install Julia
echo ""
read -p "Do you want to install Julia language for high-performance computing? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Installing Julia..."
    
    JULIA_VERSION="1.10.0"  # Latest stable as of 2024
    JULIA_URL="https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz"
    
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    curl -fsSL "$JULIA_URL" -o julia.tar.gz
    tar -xzf julia.tar.gz
    sudo mv julia-${JULIA_VERSION} /opt/julia
    sudo ln -sf /opt/julia/bin/julia /usr/local/bin/julia
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    print_success "Julia installed"
    print_info "Run 'julia' to start Julia REPL"
    print_info "Install IJulia for Jupyter: julia -e 'using Pkg; Pkg.add(\"IJulia\")'"
fi

conda deactivate

echo ""
echo "============================================"
print_success "Data science setup completed!"
echo "============================================"
echo ""
echo "Installed components:"
echo "  - Miniconda (conda package manager)"
echo "  - 'datascience' conda environment with Python 3.12"
echo "  - JupyterLab and Jupyter Notebook"
echo "  - Essential data science libraries:"
echo "    * NumPy, SciPy, Pandas"
echo "    * Matplotlib, Seaborn, Plotly"
echo "    * Scikit-learn, Statsmodels"
echo "    * And more..."
echo ""
echo "Usage:"
echo "  1. Activate environment: conda activate datascience"
echo "  2. Start JupyterLab: jupyter lab"
echo "  3. Or start Jupyter Notebook: jupyter notebook"
echo ""
echo "Note: You may need to restart your terminal or run:"
echo "  source ~/.bashrc  # or source ~/.zshrc"
echo "  conda activate datascience"
echo ""

