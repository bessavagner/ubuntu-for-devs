# Contributing to Ubuntu for Devs

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in the repository
2. Create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - System information (Ubuntu version, hardware, etc.)

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes:**
   - Follow existing code style
   - Add comments for complex logic
   - Test your changes on Ubuntu 24.04+
   - Update documentation if needed

4. **Commit your changes:**
   ```bash
   git commit -m "Add: Description of your change"
   ```
   Use clear, descriptive commit messages.

5. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request:**
   - Provide a clear description of changes
   - Reference any related issues
   - Include screenshots if applicable

## Code Style Guidelines

### Shell Scripts

- Use `#!/bin/bash` shebang
- Use 4 spaces for indentation
- Use descriptive variable names
- Add comments for complex operations
- Include error handling with `set -e`
- Use color-coded output (green for success, yellow for info, red for errors)

### Documentation

- Use Markdown format
- Keep lines under 100 characters when possible
- Include code examples
- Update README.md if adding new features

## Project Structure

```
ubuntu_for_devs/
├── scripts/              # Setup scripts
│   ├── ubuntu_setup_*.sh # Main setup scripts
│   └── utils/            # Utility scripts
├── docs/                 # Documentation
├── tests/                # Test scripts
├── README.md            # Main documentation
├── LICENSE              # MIT License
└── CONTRIBUTING.md      # This file
```

## Testing

Before submitting:

1. Test on a fresh Ubuntu 24.04 installation (or VM)
2. Verify scripts are idempotent (safe to run multiple times)
3. Check for syntax errors:
   ```bash
   bash -n script.sh
   ```
4. Test error handling

## Areas for Contribution

- Additional setup scripts for other tools
- Improvements to existing scripts
- Documentation enhancements
- Bug fixes
- Performance optimizations
- Better error messages
- Additional test scripts

## Questions?

Feel free to open an issue for questions or discussions.

Thank you for contributing! 🎉

