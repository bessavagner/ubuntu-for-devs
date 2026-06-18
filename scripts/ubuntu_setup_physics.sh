#!/bin/bash

# Physics & Scientific Computing Setup Script
# Installs LaTeX, scientific computing tools, and visualization software

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
echo "Physics & Scientific Computing Setup"
echo "============================================"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root (don't use sudo)"
   exit 1
fi

# Install LaTeX distribution
echo ""
print_info "Installing LaTeX distribution (TeX Live)..."
echo "This will install the full TeX Live distribution (~5GB)."
echo "This may take 20-30 minutes depending on your internet speed."
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command_exists pdflatex; then
        print_success "LaTeX already installed ($(pdflatex --version | head -n 1))"
    else
        print_info "Installing TeX Live (full distribution)..."
        sudo apt update
        sudo apt install -y texlive-full
        print_success "TeX Live full distribution installed"
    fi
    
    # Install additional LaTeX packages
    print_info "Installing additional LaTeX packages..."
    sudo apt install -y texlive-latex-extra texlive-science texlive-publishers \
                        texlive-bibtex-extra biber
    print_success "Additional LaTeX packages installed"
else
    print_info "Skipping LaTeX installation"
fi

# Install LaTeX editors
echo ""
print_info "Installing LaTeX editors..."
read -p "Install LaTeX editors (TeXstudio, TeXmaker)? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt update
    sudo apt install -y texstudio texmaker
    print_success "LaTeX editors installed"
fi

# Check for conda (for scientific Python libraries)
if [ ! -d "$HOME/miniconda3" ] && [ ! -d "$HOME/anaconda3" ]; then
    print_info "Conda not found. Some Python packages will be installed system-wide."
    USE_CONDA=false
else
    USE_CONDA=true
    if [ -d "$HOME/miniconda3" ]; then
        export PATH="$HOME/miniconda3/bin:$PATH"
    elif [ -d "$HOME/anaconda3" ]; then
        export PATH="$HOME/anaconda3/bin:$PATH"
    fi
fi

# Install scientific computing Python packages
echo ""
print_info "Setting up scientific Python packages..."

if [ "$USE_CONDA" = true ] && command_exists conda; then
    # Disable auto-activation of base environment
    print_info "Disabling conda base environment auto-activation..."
    conda config --set auto_activate_base false 2>/dev/null || true
    print_success "Conda base auto-activation disabled"

    # Accept Terms of Service for the default Anaconda channels.
    # Newer conda (24.x+) refuses to create environments from the default
    # channels until their ToS are accepted, raising CondaToSNonInteractiveError.
    # The `conda tos` subcommand only exists on these newer versions, so guard.
    if conda tos --help >/dev/null 2>&1; then
        print_info "Accepting Terms of Service for default conda channels..."
        conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
        conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true
        print_success "Conda channel Terms of Service accepted"
    fi

    # Use conda environment
    if conda env list | grep -q "^physics "; then
        print_success "Environment 'physics' already exists"
        read -p "Do you want to recreate it? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            conda env remove -n physics -y
            conda create -n physics python=3.12 -y -q
            print_success "Environment 'physics' recreated"
        fi
    else
        conda create -n physics python=3.12 -y -q
        print_success "Environment 'physics' created"
    fi
    
    eval "$(conda shell.bash hook)"
    conda activate physics
    pip install --quiet --upgrade pip
else
    # Install system-wide
    print_info "Installing packages system-wide (requires sudo)..."
    sudo apt update
    sudo apt install -y python3-pip python3-dev python3-venv
    pip3 install --user --upgrade pip
    PIP_CMD="pip3 install --user"
fi

# Core scientific computing libraries
print_info "Installing scientific computing libraries..."

if [ "$USE_CONDA" = true ]; then
    # Use conda for better package management
    conda install -c conda-forge numpy scipy matplotlib sympy pandas -y -q
    
    # Additional packages via pip
    pip install --quiet scipy sympy pandas matplotlib seaborn plotly
    
    # Physics-specific libraries
    pip install --quiet astropy scikit-image networkx
    
    # Symbolic mathematics
    pip install --quiet sympy
    
    # Quantum computing (optional but useful)
    echo ""
    read -p "Install quantum computing libraries (qiskit, cirq)? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pip install --quiet qiskit cirq
        print_success "Quantum computing libraries installed"
    fi
else
    # System-wide installation
    $PIP_CMD --quiet numpy scipy matplotlib sympy pandas seaborn plotly astropy scikit-image
fi

# 3D visualization
echo ""
print_info "Installing 3D visualization tools..."
read -p "Install ParaView (3D visualization - large download)? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt update
    sudo apt install -y paraview paraview-python
    print_success "ParaView installed"
fi

# Install Jupyter support for physics environment
if [ "$USE_CONDA" = true ]; then
    pip install --quiet jupyterlab notebook ipykernel
    python -m ipykernel install --user --name physics --display-name "Python (Physics)"
    conda deactivate
fi

# Install additional scientific tools
echo ""
print_info "Installing additional scientific computing tools..."

# Gnuplot
sudo apt update
sudo apt install -y gnuplot gnuplot-x11 gnuplot-doc
print_success "Gnuplot installed"

# Octave (MATLAB alternative)
echo ""
read -p "Install GNU Octave (MATLAB alternative)? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt install -y octave octave-control octave-image octave-optim octave-signal
    print_success "GNU Octave installed"
fi

# Reference management
echo ""
print_info "Installing reference management tools..."
read -p "Install Zotero (reference manager) via Flatpak? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command_exists flatpak; then
        flatpak install -y flathub org.zotero.Zotero
        print_success "Zotero installed"
    else
        print_error "Flatpak not installed. Install it first with ubuntu_setup_main.sh"
    fi
fi

# Install physics simulation software (optional)
echo ""
print_info "Physics simulation software..."
read -p "Install molecular dynamics tools (GROMACS, VMD)? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt update
    sudo apt install -y gromacs gromacs-data vmd
    print_success "Molecular dynamics tools installed"
fi

# Install additional plotting tools
sudo apt install -y grace grace-doc
print_success "Grace plotting tool installed"

echo ""
echo "============================================"
print_success "Physics & Scientific computing setup completed!"
echo "============================================"
echo ""
echo "Installed components:"
if command_exists pdflatex; then
    echo "  - LaTeX (TeX Live full distribution)"
fi
if [ "$USE_CONDA" = true ]; then
    echo "  - 'physics' conda environment"
fi
echo "  - Scientific Python libraries: NumPy, SciPy, SymPy"
echo "  - Visualization: Matplotlib, Plotly, ParaView (if selected)"
echo "  - Gnuplot for data plotting"
echo "  - Additional scientific tools"
echo ""
echo "Usage:"
if [ "$USE_CONDA" = true ]; then
    echo "  1. Activate environment: conda activate physics"
    echo "  2. Start JupyterLab: jupyter lab"
fi
echo ""
echo "LaTeX usage:"
echo "  pdflatex document.tex  # Compile LaTeX document"
echo "  texstudio              # Launch TeXstudio editor"
echo ""

