# LLM Model Recommendations for Local Development

A guide to selecting and running Large Language Models locally using Ollama, optimized for different GPU configurations.

## Understanding Your GPU

Before selecting models, check your GPU specifications:

```bash
# Check NVIDIA GPU
nvidia-smi

# Check available VRAM
nvidia-smi --query-gpu=memory.total --format=csv,noheader

# Monitor VRAM usage
watch -n 1 nvidia-smi
```

### VRAM Guidelines

- **4-6GB VRAM**: 7B models (4-bit quantization)
- **6-8GB VRAM**: 7B-8B models comfortably, 13B models with 4-bit quantization
- **8-12GB VRAM**: 13B-14B models, multiple 7B models
- **12GB+ VRAM**: 13B+ models, larger models, or multiple models

## Recommended Models by Use Case

### 🟢 Best Fit (7B-8B Models - Most Common)

These models fit comfortably in 6-8GB VRAM with 4-bit quantization:

#### 1. **DeepSeek-R1:7b**
- **Size**: ~4.5GB (Q4_K_M quantization)
- **Performance**: Excellent reasoning, good for coding
- **Install**: `ollama pull deepseek-r1:7b`
- **Use case**: General purpose, coding, reasoning
- **Best for**: Complex problem-solving, code generation

#### 2. **Llama 3.1 8B**
- **Size**: ~4.7GB (Q4_K_M)
- **Performance**: Strong general purpose model
- **Install**: `ollama pull llama3.1:8b`
- **Use case**: General conversation, instruction following
- **Best for**: Balanced performance across tasks

#### 3. **Mistral 7B**
- **Size**: ~4.1GB (Q4_K_M)
- **Performance**: Fast, efficient, good quality
- **Install**: `ollama pull mistral:7b`
- **Use case**: Fast responses, general purpose
- **Best for**: Quick interactions, low latency

#### 4. **Qwen2.5 7B**
- **Size**: ~4.5GB (Q4_K_M)
- **Performance**: Excellent multilingual support
- **Install**: `ollama pull qwen2.5:7b`
- **Use case**: Multilingual tasks, coding
- **Best for**: Non-English languages, international projects

#### 5. **CodeLlama 7B**
- **Size**: ~4.5GB (Q4_K_M)
- **Performance**: Best for coding tasks
- **Install**: `ollama pull codellama:7b`
- **Use case**: Code generation, debugging, explanations
- **Best for**: Software development, code review

### 🟡 Good Options (13B Models - Requires More VRAM)

These work with 4-bit quantization but need 8GB+ VRAM:

#### 6. **Llama 3.1 13B**
- **Size**: ~7.2GB (Q4_K_M)
- **Performance**: Better than 8B, but uses most VRAM
- **Install**: `ollama pull llama3.1:13b`
- **Note**: May need to close other GPU applications
- **Best for**: Higher quality responses when you have VRAM

#### 7. **Qwen2.5 14B**
- **Size**: ~7.8GB (Q4_K_M)
- **Performance**: Very capable, multilingual
- **Install**: `ollama pull qwen2.5:14b`
- **Note**: Close other GPU apps before running
- **Best for**: Maximum quality with multilingual support

#### 8. **Phi-3 Medium (14B)**
- **Size**: ~7.5GB (Q4_K_M)
- **Performance**: Excellent reasoning, Microsoft model
- **Install**: `ollama pull phi3:14b`
- **Use case**: Complex reasoning, math, coding
- **Best for**: Mathematical problems, logical reasoning

### 🔵 Specialized Models

#### 9. **Neural Chat 7B**
- **Size**: ~4.5GB
- **Performance**: Good conversational model
- **Install**: `ollama pull neural-chat:7b`
- **Best for**: Natural conversations, chat applications

#### 10. **Gemma 7B**
- **Size**: ~4.5GB
- **Performance**: Google's open model
- **Install**: `ollama pull gemma:7b`
- **Best for**: General purpose, Google ecosystem

## Quantization Levels Explained

Ollama automatically uses appropriate quantization. Understanding the levels:

- **Q4_K_M** (Recommended): 4-bit quantization, best balance of quality/size
- **Q5_K_M**: 5-bit, slightly better quality, larger size
- **Q8_0**: 8-bit, near full precision, may not fit 13B+ models
- **F16**: Full precision, only for small models (<3B)

## Recommended Setup by GPU

### For 4-6GB VRAM:
```bash
ollama pull mistral:7b          # Smallest, fastest
ollama pull llama3.1:8b          # Best general purpose
ollama pull codellama:7b         # Best for coding
```

### For 6-8GB VRAM:
```bash
ollama pull deepseek-r1:7b       # Best reasoning
ollama pull llama3.1:8b          # Best general purpose
ollama pull qwen2.5:7b          # Best multilingual
ollama pull codellama:7b         # Best for code
```

### For 8GB+ VRAM:
```bash
# You can run 7B models comfortably
ollama pull deepseek-r1:7b
ollama pull llama3.1:8b
ollama pull codellama:7b

# Or try 13B models (may be tight)
ollama pull llama3.1:13b        # Best quality that fits
ollama pull qwen2.5:14b         # Best multilingual quality
```

### For 12GB+ VRAM:
```bash
# All 7B-8B models
# All 13B-14B models
# Can run multiple models simultaneously
```

## Use Case Recommendations

### For General Development:
```bash
ollama pull deepseek-r1:7b       # Best reasoning
ollama pull llama3.1:8b          # Best general purpose
ollama pull qwen2.5:7b          # Best multilingual
```

### For Coding:
```bash
ollama pull codellama:7b         # Best for code
ollama pull deepseek-r1:7b      # Also excellent for coding
```

### For Research/Academic:
```bash
ollama pull llama3.1:13b        # Best quality
ollama pull phi3:14b            # Best for reasoning
```

### For Multilingual Projects:
```bash
ollama pull qwen2.5:7b          # Best multilingual support
ollama pull qwen2.5:14b         # Higher quality multilingual
```

## Performance Tips

1. **Close other GPU applications** when running larger models (13B+)
2. **Use 4-bit quantization** (Q4_K_M) for best size/quality balance
3. **Monitor VRAM usage**: `watch -n 1 nvidia-smi`
4. **Batch size**: Smaller batch sizes use less VRAM
5. **Context length**: Shorter contexts use less VRAM
6. **Model switching**: Ollama loads models on-demand, so you can have multiple models installed

## Testing Models

After pulling a model, test it:

```bash
# Test DeepSeek
ollama run deepseek-r1:7b "Explain quantum computing in simple terms"

# Test Llama
ollama run llama3.1:8b "Write a Python function to calculate fibonacci"

# Test CodeLlama
ollama run codellama:7b "Write a REST API in Python using FastAPI"

# Test Qwen (multilingual)
ollama run qwen2.5:7b "Translate 'Hello, how are you?' to Spanish, French, and German"
```

## Model Comparison

| Model | Size (Q4) | Quality | Speed | Best For | VRAM Needed |
|-------|-----------|---------|-------|----------|-------------|
| DeepSeek-R1:7b | 4.5GB | ⭐⭐⭐⭐⭐ | Fast | Reasoning, Coding | 6GB+ |
| Llama 3.1 8B | 4.7GB | ⭐⭐⭐⭐⭐ | Fast | General purpose | 6GB+ |
| Qwen2.5 7B | 4.5GB | ⭐⭐⭐⭐ | Fast | Multilingual | 6GB+ |
| Mistral 7B | 4.1GB | ⭐⭐⭐⭐ | Very Fast | Quick responses | 5GB+ |
| Llama 3.1 13B | 7.2GB | ⭐⭐⭐⭐⭐ | Medium | Best quality | 8GB+ |
| CodeLlama 7B | 4.5GB | ⭐⭐⭐⭐⭐ | Fast | Code generation | 6GB+ |
| Qwen2.5 14B | 7.8GB | ⭐⭐⭐⭐⭐ | Medium | Multilingual quality | 8GB+ |
| Phi-3 14B | 7.5GB | ⭐⭐⭐⭐⭐ | Medium | Reasoning, Math | 8GB+ |

## Managing Models

```bash
# List installed models
ollama list

# Remove a model
ollama rm <model-name>

# Show model information
ollama show <model-name>

# Copy a model
ollama cp <source> <destination>
```

## Troubleshooting

### Out of Memory
- Use smaller models (7B instead of 13B)
- Close other GPU applications
- Monitor VRAM: `watch -n 1 nvidia-smi`

### Slow Performance
- Check if GPU is being used: `nvidia-smi`
- Ensure CUDA is properly installed
- Try smaller models or lower quantization

### Model Not Found
- Check model name spelling
- Visit https://ollama.com/library for available models
- Ensure you have internet connection

## Resources

- **Ollama model library**: https://ollama.com/library
- **Model cards and benchmarks**: https://huggingface.co/models
- **Quantization guide**: https://github.com/ggerganov/llama.cpp
- **Ollama documentation**: https://github.com/ollama/ollama

## Next Steps

1. **Check your GPU VRAM**: `nvidia-smi`
2. **Start with a 7B model** that fits your VRAM
3. **Test different models** to find what works best for your use case
4. **Monitor performance** and VRAM usage
5. **Install multiple models** - Ollama loads them on-demand

---

**Note**: Model sizes and performance may vary. Always test models with your specific hardware and use cases.
