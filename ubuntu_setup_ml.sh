#!/bin/bash

# Machine Learning Setup Script
# Installs TensorFlow, PyTorch, CUDA (if GPU available), and ML tools

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
echo "Machine Learning Environment Setup"
echo "============================================"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root (don't use sudo)"
   exit 1
fi

# Detect NVIDIA GPU
print_info "Checking for NVIDIA GPU..."
HAS_NVIDIA_GPU=false
if command_exists nvidia-smi; then
    NVIDIA_DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -n 1)
    print_success "NVIDIA GPU detected! Driver version: $NVIDIA_DRIVER_VERSION"
    HAS_NVIDIA_GPU=true
elif lspci | grep -i nvidia > /dev/null 2>&1; then
    print_info "NVIDIA GPU hardware detected but driver not installed"
    echo ""
    read -p "Do you want to install NVIDIA drivers? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing NVIDIA drivers..."
        sudo ubuntu-drivers autoinstall
        print_success "NVIDIA drivers installed. Please reboot and run this script again."
        exit 0
    else
        print_info "Skipping NVIDIA driver installation. Will install CPU-only ML frameworks."
    fi
else
    print_info "No NVIDIA GPU detected. Installing CPU-only ML frameworks."
fi

# Check for conda
if [ ! -d "$HOME/miniconda3" ] && [ ! -d "$HOME/anaconda3" ]; then
    print_error "Conda not found. Please run ubuntu_setup_datascience.sh first"
    exit 1
fi

# Add conda to PATH
if [ -d "$HOME/miniconda3" ]; then
    export PATH="$HOME/miniconda3/bin:$PATH"
elif [ -d "$HOME/anaconda3" ]; then
    export PATH="$HOME/anaconda3/bin:$PATH"
fi

if ! command_exists conda; then
    print_error "Conda not available in PATH"
    exit 1
fi

# Create or use ML environment
echo ""
print_info "Setting up ML conda environment..."
if conda env list | grep -q "^ml "; then
    print_success "Environment 'ml' already exists"
    read -p "Do you want to recreate it? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        conda env remove -n ml -y
        conda create -n ml python=3.12 -y -q
        print_success "Environment 'ml' recreated"
    fi
else
    conda create -n ml python=3.12 -y -q
    print_success "Environment 'ml' created"
fi

# Activate environment
eval "$(conda shell.bash hook)"
conda activate ml

print_info "Installing ML packages..."

# Upgrade pip
pip install --quiet --upgrade pip

# Install CUDA toolkit if GPU available
if [ "$HAS_NVIDIA_GPU" = true ]; then
    echo ""
    print_info "GPU detected - Setting up CUDA support..."
    
    # Install CUDA toolkit via conda (easier than system-wide)
    print_info "Installing CUDA toolkit via conda..."
    conda install -c conda-forge cudatoolkit=11.8 cudnn=8.1 -y -q || conda install -c nvidia cuda-toolkit -y -q
    print_success "CUDA toolkit installed"
fi

# Install PyTorch
echo ""
print_info "Installing PyTorch..."
if [ "$HAS_NVIDIA_GPU" = true ]; then
    # GPU version
    print_info "Installing PyTorch with CUDA support..."
    pip install --quiet torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    print_success "PyTorch (GPU) installed"
else
    # CPU version
    pip install --quiet torch torchvision torchaudio
    print_success "PyTorch (CPU) installed"
fi

# Install TensorFlow
echo ""
print_info "Installing TensorFlow..."
if [ "$HAS_NVIDIA_GPU" = true ]; then
    # GPU version
    pip install --quiet tensorflow[and-cuda]
    print_success "TensorFlow (GPU) installed"
else
    # CPU version
    pip install --quiet tensorflow
    print_success "TensorFlow (CPU) installed"
fi

# Install additional ML libraries
print_info "Installing additional ML libraries..."

# Core ML libraries
pip install --quiet scikit-learn xgboost lightgbm catboost

# Deep learning utilities
pip install --quiet keras transformers datasets accelerate

# Computer vision
pip install --quiet opencv-python pillow

# Natural language processing
pip install --quiet nltk spacy gensim

# ML experiment tracking and MLOps
pip install --quiet mlflow wandb tensorboard

# Data version control
pip install --quiet dvc dvc-s3

# Jupyter support
pip install --quiet jupyterlab notebook ipykernel

# Register kernel
python -m ipykernel install --user --name ml --display-name "Python (ML)"

# Additional utilities
pip install --quiet tqdm pandas numpy matplotlib seaborn plotly

print_success "ML libraries installed"

# Verify installations
echo ""
print_info "Verifying installations..."

# Check PyTorch
python -c "import torch; print(f'PyTorch {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda if torch.cuda.is_available() else \"N/A\"}')" 2>/dev/null && print_success "PyTorch verification passed" || print_error "PyTorch verification failed"

# Check TensorFlow
python -c "import tensorflow as tf; print(f'TensorFlow {tf.__version__}'); print(f'GPU available: {len(tf.config.list_physical_devices(\"GPU\")) > 0}')" 2>/dev/null && print_success "TensorFlow verification passed" || print_error "TensorFlow verification failed"

conda deactivate

# Note: DVC is installed in the conda environment above
# No system-wide ML packages are installed to keep the environment isolated

echo ""
echo "============================================"
print_success "Machine Learning setup completed!"
echo "============================================"
echo ""
echo "Installed components:"
echo "  - 'ml' conda environment with Python 3.12"
if [ "$HAS_NVIDIA_GPU" = true ]; then
    echo "  - CUDA toolkit for GPU acceleration"
    echo "  - PyTorch with CUDA support"
    echo "  - TensorFlow with GPU support"
else
    echo "  - PyTorch (CPU version)"
    echo "  - TensorFlow (CPU version)"
fi
echo "  - ML libraries: scikit-learn, XGBoost, LightGBM"
echo "  - Deep learning: Keras, Transformers"
echo "  - MLOps tools: MLflow, Weights & Biases, TensorBoard"
echo "  - Data versioning: DVC"
echo ""
echo "Usage:"
echo "  1. Activate environment: conda activate ml"
echo "  2. Start JupyterLab: jupyter lab"
echo ""
echo "Verify GPU support (in ml environment):"
echo "  python -c \"import torch; print(torch.cuda.is_available())\""
echo "  python -c \"import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))\""
echo ""

