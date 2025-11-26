#!/usr/bin/env python3
"""
CUDA Installation Test Script
Tests CUDA availability, GPU information, and framework support
"""

import sys
import subprocess
from datetime import datetime

def print_header(text):
    """Print a formatted header"""
    print("\n" + "=" * 60)
    print(f"  {text}")
    print("=" * 60)

def print_section(text):
    """Print a section header"""
    print(f"\n{'─' * 60}")
    print(f"  {text}")
    print(f"{'─' * 60}")

def run_command(cmd):
    """Run a shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
        return result.stdout.strip(), result.returncode == 0
    except subprocess.TimeoutExpired:
        return "Command timed out", False
    except Exception as e:
        return str(e), False

def check_nvidia_smi():
    """Check if nvidia-smi is available"""
    print_section("NVIDIA Driver & CUDA Check")
    
    output, success = run_command("nvidia-smi")
    if success:
        print("✓ nvidia-smi is available")
        print("\nGPU Information:")
        print(output)
        return True
    else:
        print("✗ nvidia-smi not found or not working")
        print(f"Error: {output}")
        return False

def check_cuda_version():
    """Check CUDA version"""
    print_section("CUDA Version")
    
    # Check nvcc
    output, success = run_command("nvcc --version")
    if success:
        print("✓ CUDA compiler (nvcc) found:")
        # Extract version from output
        for line in output.split('\n'):
            if 'release' in line.lower():
                print(f"  {line.strip()}")
        return True
    else:
        print("✗ nvcc not found")
        print("  (This is okay if using conda CUDA toolkit)")
        return False

def check_pytorch():
    """Check PyTorch CUDA support"""
    print_section("PyTorch CUDA Support")
    
    try:
        import torch
        print(f"✓ PyTorch version: {torch.__version__}")
        
        # Check CUDA availability
        cuda_available = torch.cuda.is_available()
        if cuda_available:
            print(f"✓ CUDA is available in PyTorch")
            print(f"  CUDA version: {torch.version.cuda}")
            print(f"  cuDNN version: {torch.backends.cudnn.version()}")
            print(f"  Number of GPUs: {torch.cuda.device_count()}")
            
            # Get GPU information
            for i in range(torch.cuda.device_count()):
                print(f"\n  GPU {i}: {torch.cuda.get_device_name(i)}")
                props = torch.cuda.get_device_properties(i)
                print(f"    Total Memory: {props.total_memory / 1024**3:.2f} GB")
                print(f"    Compute Capability: {props.major}.{props.minor}")
            
            # Test a simple CUDA operation
            print("\n  Testing CUDA operations...")
            try:
                x = torch.randn(1000, 1000).cuda()
                y = torch.randn(1000, 1000).cuda()
                z = torch.matmul(x, y)
                print("  ✓ CUDA tensor operations working")
                
                # Test memory allocation
                del x, y, z
                torch.cuda.empty_cache()
                print("  ✓ CUDA memory management working")
                
                return True
            except Exception as e:
                print(f"  ✗ CUDA operations failed: {e}")
                return False
        else:
            print("✗ CUDA is NOT available in PyTorch")
            print("  PyTorch was likely installed without CUDA support")
            return False
            
    except ImportError:
        print("✗ PyTorch is not installed")
        print("  Install with: pip install torch")
        return False
    except Exception as e:
        print(f"✗ Error checking PyTorch: {e}")
        return False

def check_tensorflow():
    """Check TensorFlow CUDA support"""
    print_section("TensorFlow CUDA Support")
    
    try:
        import tensorflow as tf
        print(f"✓ TensorFlow version: {tf.__version__}")
        
        # Check GPU availability
        gpus = tf.config.list_physical_devices('GPU')
        if gpus:
            print(f"✓ TensorFlow found {len(gpus)} GPU(s):")
            for i, gpu in enumerate(gpus):
                print(f"  GPU {i}: {gpu.name}")
                try:
                    details = tf.config.experimental.get_device_details(gpu)
                    if details:
                        print(f"    Device details: {details}")
                except:
                    pass
            
            # Test GPU operations
            print("\n  Testing TensorFlow GPU operations...")
            try:
                with tf.device('/GPU:0'):
                    a = tf.constant([[1.0, 2.0], [3.0, 4.0]])
                    b = tf.constant([[1.0, 1.0], [0.0, 1.0]])
                    c = tf.matmul(a, b)
                    print("  ✓ TensorFlow GPU operations working")
                    print(f"    Test result: {c.numpy()}")
                return True
            except Exception as e:
                print(f"  ✗ TensorFlow GPU operations failed: {e}")
                return False
        else:
            print("✗ No GPUs found by TensorFlow")
            print("  TensorFlow was likely installed without GPU support")
            return False
            
    except ImportError:
        print("✗ TensorFlow is not installed")
        print("  Install with: pip install tensorflow[and-cuda]")
        return False
    except Exception as e:
        print(f"✗ Error checking TensorFlow: {e}")
        return False

def check_cupy():
    """Check CuPy (optional, for NumPy-like GPU operations)"""
    print_section("CuPy (Optional - NumPy for GPU)")
    
    try:
        import cupy as cp
        print(f"✓ CuPy version: {cp.__version__}")
        print(f"  CUDA version: {cp.cuda.runtime.runtimeGetVersion()}")
        print(f"  Available devices: {cp.cuda.runtime.getDeviceCount()}")
        
        # Test CuPy operations
        print("\n  Testing CuPy operations...")
        x = cp.array([1, 2, 3, 4, 5])
        y = cp.array([5, 4, 3, 2, 1])
        z = x + y
        print(f"  ✓ CuPy operations working: {z}")
        return True
    except ImportError:
        print("✗ CuPy is not installed (optional)")
        print("  Install with: pip install cupy-cuda12x (adjust for your CUDA version)")
        return False
    except Exception as e:
        print(f"✗ Error checking CuPy: {e}")
        return False

def performance_test():
    """Run a simple performance test"""
    print_section("Performance Test")
    
    try:
        import torch
        
        if not torch.cuda.is_available():
            print("✗ Skipping performance test (CUDA not available)")
            return False
        
        print("Running matrix multiplication benchmark...")
        
        # CPU test
        import time
        size = 2000
        a_cpu = torch.randn(size, size)
        b_cpu = torch.randn(size, size)
        
        start = time.time()
        c_cpu = torch.matmul(a_cpu, b_cpu)
        cpu_time = time.time() - start
        
        # GPU test
        a_gpu = torch.randn(size, size).cuda()
        b_gpu = torch.randn(size, size).cuda()
        
        # Warmup
        _ = torch.matmul(a_gpu, b_gpu)
        torch.cuda.synchronize()
        
        start = time.time()
        c_gpu = torch.matmul(a_gpu, b_gpu)
        torch.cuda.synchronize()
        gpu_time = time.time() - start
        
        speedup = cpu_time / gpu_time if gpu_time > 0 else 0
        
        print(f"  Matrix size: {size}x{size}")
        print(f"  CPU time: {cpu_time:.4f} seconds")
        print(f"  GPU time: {gpu_time:.4f} seconds")
        print(f"  Speedup: {speedup:.2f}x")
        
        if speedup > 1:
            print("  ✓ GPU is faster than CPU")
        else:
            print("  ⚠ GPU is not faster (may need larger matrices)")
        
        return True
        
    except Exception as e:
        print(f"✗ Performance test failed: {e}")
        return False

def main():
    """Main test function"""
    print_header("CUDA Installation Test")
    print(f"Test run at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Python version: {sys.version}")
    
    results = {
        'nvidia_smi': False,
        'cuda_version': False,
        'pytorch': False,
        'tensorflow': False,
        'cupy': False,
        'performance': False
    }
    
    # Run tests
    results['nvidia_smi'] = check_nvidia_smi()
    results['cuda_version'] = check_cuda_version()
    results['pytorch'] = check_pytorch()
    results['tensorflow'] = check_tensorflow()
    check_cupy()  # Optional, don't count as failure
    if results['pytorch']:
        results['performance'] = performance_test()
    
    # Summary
    print_header("Test Summary")
    
    critical_tests = ['nvidia_smi', 'pytorch']
    passed = sum(1 for test in critical_tests if results[test])
    total = len(critical_tests)
    
    print(f"\nCritical Tests: {passed}/{total} passed")
    print(f"  {'✓' if results['nvidia_smi'] else '✗'} NVIDIA Driver")
    print(f"  {'✓' if results['pytorch'] else '✗'} PyTorch CUDA")
    print(f"\nOptional Tests:")
    print(f"  {'✓' if results['tensorflow'] else '✗'} TensorFlow CUDA")
    print(f"  {'✓' if results['cuda_version'] else '✗'} CUDA Compiler (nvcc)")
    print(f"  {'✓' if results['performance'] else '✗'} Performance Test")
    
    if results['nvidia_smi'] and results['pytorch']:
        print("\n✓ CUDA installation appears to be working correctly!")
        return 0
    else:
        print("\n✗ CUDA installation has issues. Check the errors above.")
        if not results['nvidia_smi']:
            print("\n  → Install NVIDIA drivers: sudo ubuntu-drivers autoinstall")
        if not results['pytorch']:
            print("\n  → Install PyTorch with CUDA: pip install torch --index-url https://download.pytorch.org/whl/cu118")
        return 1

if __name__ == "__main__":
    sys.exit(main())




