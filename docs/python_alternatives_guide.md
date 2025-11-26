# Python Alternatives Guide

## Understanding update-alternatives

The `update-alternatives` command allows you to manage multiple versions of the same program and switch between them easily.

## Current Status

Your system has:
- **Python 3.12** installed at `/usr/bin/python3.12`
- **Python 3.13.9** from Miniconda at `/home/bessa/miniconda3/bin/python3`
- Currently active: Miniconda's Python 3.13.9 (because conda is in your PATH)

## Basic Syntax

```bash
sudo update-alternatives --install <link> <name> <path> <priority>
```

Where:
- `<link>` = The symlink that will point to alternatives (e.g., `/usr/bin/python3`)
- `<name>` = The name of the alternative group (e.g., `python3`)
- `<path>` = The actual executable path (e.g., `/usr/bin/python3.12`)
- `<priority>` = Higher number = higher priority (default choice)

## Common Commands

### 1. Add a Python version to alternatives

```bash
# Add Python 3.12
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Add Python 3.11 (if installed)
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2

# Add Python 3.10 (if installed)
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 3
```

**Note:** Higher priority number = higher priority (will be default)

### 2. List all configured alternatives

```bash
update-alternatives --list python3
```

### 3. Display detailed information

```bash
update-alternatives --display python3
```

### 4. Manually select which version to use

```bash
sudo update-alternatives --config python3
```

This will show an interactive menu to choose.

### 5. Remove a version from alternatives

```bash
sudo update-alternatives --remove python3 /usr/bin/python3.11
```

### 6. Set a specific version (non-interactive)

```bash
sudo update-alternatives --set python3 /usr/bin/python3.12
```

## Example: Setting up Multiple Python Versions

```bash
# 1. Install Python versions (if not already installed)
sudo apt install python3.10 python3.11 python3.12

# 2. Add them to alternatives
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 3

# 3. Check what's configured
update-alternatives --display python3

# 4. Switch between versions
sudo update-alternatives --config python3
```

## Important Notes

### ⚠️ System Python vs Conda Python

If you have Conda/Miniconda installed, it modifies your PATH, so `python3` might point to conda's Python instead of system Python.

**To use system Python:**
```bash
# Temporarily
/usr/bin/python3 --version

# Permanently (if conda is in PATH)
# Edit ~/.zshrc or ~/.bashrc and move conda initialization to the end
# Or use full path: /usr/bin/python3
```

### ⚠️ Don't Break System Tools

Some system tools depend on specific Python versions. Be careful when changing the default.

**Safe approach:**
- Keep system Python as default for system tools
- Use virtual environments (venv/conda) for projects
- Use specific Python versions directly: `python3.12`, `python3.11`, etc.

## Best Practices

1. **Use virtual environments** instead of changing system Python
   ```bash
   python3.12 -m venv myproject
   source myproject/bin/activate
   ```

2. **Use specific Python versions** for projects
   ```bash
   python3.12 script.py
   python3.11 script.py
   ```

3. **Keep system Python stable** - Don't change `/usr/bin/python3` unless necessary

4. **Use Conda environments** for data science/ML projects
   ```bash
   conda create -n myenv python=3.12
   conda activate myenv
   ```

## Troubleshooting

### Check which Python is active
```bash
which python3
python3 --version
```

### Check all Python versions
```bash
ls -la /usr/bin/python3*
update-alternatives --list python3
```

### Reset to system default
```bash
sudo update-alternatives --set python3 /usr/bin/python3.12
```

## Your Current Setup

Based on your system:
- System Python: `/usr/bin/python3.12` (Python 3.12)
- Conda Python: `/home/bessa/miniconda3/bin/python3` (Python 3.13.9)
- Active: Conda's Python (because it's first in PATH)

**To use system Python 3.12:**
```bash
/usr/bin/python3.12 --version
```

**To use conda Python:**
```bash
python3 --version  # (if conda is in PATH)
```



