# LLM Terminal Integration Guide

This guide explains how to use LLMs directly from your terminal using the integrated commands.

## Quick Start

After running `./scripts/utils/add_llm_to_terminal.sh`, you'll have access to convenient LLM commands:

```bash
# Reload your shell configuration
source ~/.zshrc  # or source ~/.bashrc

# Ask a quick question
llm "What is machine learning?"

# Start an interactive chat session
llm-chat
```

## Available Commands

### 📝 Quick Commands

#### `llm "your question"`
Ask a quick question and get an immediate response.

**Examples:**
```bash
llm "Explain quantum computing"
llm "Write a Python function to reverse a string"
llm "What are the benefits of using Docker?"
```

#### `llm-chat`
Start an interactive chat session. Type your questions and get responses. Type `exit`, `quit`, or press `Ctrl+D` to end.

**Example:**
```bash
llm-chat
# Then type your questions interactively
```

### 🔧 Model Management

#### `llm-list`
List all available models on your system.

```bash
llm-list
```

#### `llm-use <model-name>`
Switch to a different model for the current terminal session.

**Examples:**
```bash
llm-use llama3.1:8b
llm-use codellama:7b
llm-use qwen2.5:7b
```

**Note:** This only affects the current terminal session. To make it permanent, edit `DEFAULT_LLM_MODEL` in `~/.zshrc` or `~/.bashrc`.

#### `llm-pull <model-name>`
Download a new model from Ollama.

**Examples:**
```bash
llm-pull llama3.1:8b
llm-pull codellama:7b
llm-pull qwen2.5:7b
```

#### `llm-info`
Show information about the current model.

```bash
llm-info
```

### 💻 Code Helpers

#### `llm-explain <code-or-file>`
Get an explanation of code. You can pass code directly or a file path.

**Examples:**
```bash
# Explain code from a file
llm-explain script.py

# Explain inline code
llm-explain "def fibonacci(n): return n if n <= 1 else fibonacci(n-1) + fibonacci(n-2)"
```

#### `llm-review <file>`
Get a code review with suggestions for improvements.

**Example:**
```bash
llm-review my_script.py
```

### 🌍 Utilities

#### `llm-translate <text> <target-language>`
Translate text to another language.

**Examples:**
```bash
llm-translate "Hello, how are you?" Spanish
llm-translate "Bonjour le monde" English
llm-translate "Guten Tag" Portuguese
```

## Configuration

### Setting Default Model

The default model is set when you run `scripts/utils/add_llm_to_terminal.sh`. To change it permanently:

1. Edit `~/.zshrc` (or `~/.bashrc` if using bash)
2. Find the line: `export DEFAULT_LLM_MODEL="deepseek-r1:7b"`
3. Change it to your preferred model
4. Reload: `source ~/.zshrc`

### Using Different Models Per Session

```bash
# Switch model for current session
llm-use llama3.1:8b

# Now all llm commands use this model
llm "Hello"
```

## Common Use Cases

### 1. Quick Code Help
```bash
llm "How do I sort a list in Python?"
llm "Write a bash script to backup files"
```

### 2. Code Explanation
```bash
llm-explain complex_function.py
```

### 3. Code Review
```bash
llm-review new_feature.py
```

### 4. Learning
```bash
llm-chat
# Then ask follow-up questions interactively
```

### 5. Translation
```bash
llm-translate "Hello world" French
```

### 6. Documentation
```bash
llm "Explain the difference between REST and GraphQL"
```

## Tips & Tricks

### 1. Multi-line Questions
For complex questions, use quotes:
```bash
llm "Explain the following concept: Machine learning is a subset of artificial intelligence that enables systems to learn from data without being explicitly programmed."
```

### 2. Code Generation
```bash
llm "Write a Python class for a REST API client with methods for GET, POST, PUT, DELETE"
```

### 3. Debugging Help
```bash
llm "I'm getting this error: 'ModuleNotFoundError: No module named xyz'. How do I fix it?"
```

### 4. Learning Paths
```bash
llm-chat
# Then ask: "What should I learn to become a full-stack developer?"
# Follow up with more questions
```

### 5. File Operations
```bash
# Explain a configuration file
llm-explain ~/.zshrc

# Review a script
llm-review deploy.sh
```

## Troubleshooting

### Command Not Found
If you get `command not found`:
```bash
# Reload shell configuration
source ~/.zshrc  # for zsh
# or
source ~/.bashrc  # for bash
```

### Model Not Found
If you get model errors:
```bash
# Check available models
llm-list

# Pull the model if missing
llm-pull <model-name>
```

### Ollama Not Running
If Ollama commands fail:
```bash
# Check Ollama service
systemctl --user status ollama

# Start Ollama if needed
ollama serve
```

### Slow Responses
- Use smaller models (7B instead of 13B)
- Close other GPU applications
- Check GPU memory: `nvidia-smi`

## Advanced Usage

### Combining with Other Commands

```bash
# Pipe output to LLM
cat config.json | llm "Explain this configuration"

# Use with grep
grep -r "TODO" . | llm "Summarize these todos"
```

### Environment Variables

You can set the model via environment variable:
```bash
export LLM_MODEL=llama3.1:8b
llm "Hello"
```

### Script Integration

Use in scripts:
```bash
#!/bin/bash
ANSWER=$(llm "What is 2+2?")
echo "The answer is: $ANSWER"
```

## Model Recommendations

Based on your GPU (RTX 4060, 8GB VRAM):

**Best Fit (7B-8B models, ~4-5GB each):**
- `deepseek-r1:7b` - Best reasoning & coding
- `llama3.1:8b` - Best general purpose
- `codellama:7b` - Best for coding tasks
- `qwen2.5:7b` - Best multilingual support
- `mistral:7b` - Fast responses

**Larger Models (13B-14B, ~7-8GB - may be tight):**
- `llama3.1:13b` - Higher quality
- `qwen2.5:14b` - Higher quality, multilingual

See `LLM_RECOMMENDATIONS.md` for more details.

## Examples

### Development Workflow
```bash
# Quick question while coding
llm "How do I use async/await in Python?"

# Explain unfamiliar code
llm-explain legacy_code.py

# Review before commit
llm-review new_feature.py
```

### Learning
```bash
# Start interactive session
llm-chat
# Ask: "Explain neural networks"
# Follow up: "How do they differ from traditional algorithms?"
```

### Documentation
```bash
# Generate documentation
llm "Write documentation for this function: $(cat my_function.py)"
```

## Integration with Setup Scripts

The terminal integration is automatically offered when you run:
```bash
./scripts/ubuntu_setup_ollama.sh
```

Or install it separately:
```bash
./scripts/utils/add_llm_to_terminal.sh
```

## Quick Reference

### Switching Between Models

**For current session:**
```bash
llm-use codellama:7b    # Switch to CodeLlama
llm "coding question"

llm-use deepseek-r1:7b  # Switch back to DeepSeek
llm "reasoning question"
```

**For one command:**
```bash
LLM_MODEL=codellama:7b llm "question"
LLM_MODEL=deepseek-r1:7b llm "question"
```

**Change default permanently:**
```bash
./scripts/utils/switch_llm_model.sh codellama:7b
source ~/.zshrc
```

### Model Recommendations

- **CodeLlama:7b** - Best for code generation, code explanation, programming questions
- **DeepSeek-R1:7b** - Best for reasoning tasks, general questions, complex explanations

---

**Enjoy using LLMs directly from your terminal!** 🚀

For more information:
- Ollama documentation: https://ollama.com
- Model library: https://ollama.com/library
- Troubleshooting: See `TROUBLESHOOTING.md`

