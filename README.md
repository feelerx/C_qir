# C to QIR Transformation Pass

A C-based quantum-classical execution framework that seamlessly integrates with Quantum Intermediate Representation (QIR), allowing quantum programs to be written in C while leveraging LLVM's compiler infrastructure for QIR generation, optimization, and execution.

## Abstract

This project addresses the gap in lightweight, C-based quantum programming models by developing a framework that integrates Quantum Intermediate Representation (QIR) into C-based quantum computing. While existing QIR implementations primarily target high-level quantum programming languages such as Q# and Python, this framework enables quantum programs to be written in C while maintaining full compatibility with the QIR standard.

The framework provides:
- A C API for quantum programming using simple intrinsics
- A Clang-based frontend for parsing and transformation
- An LLVM-backed compilation pipeline that generates QIR-compatible IR
- Compatibility with existing QIR runtimes and quantum frameworks

By leveraging LLVM and QIR, this project evaluates the performance, optimization potential, and portability of a QIR-based quantum-classical execution model in C.

## Features

- **C Quantum Intrinsics**: Write quantum programs using simple C function calls (`qc_h`, `qc_x`, `qc_cnot`, `qc_measure`)
- **QIR Compatibility**: Generates standard QIR output compatible with Microsoft's QIR specification
- **LLVM Integration**: Built as an LLVM pass for seamless integration with existing toolchains
- **Runtime Optimization**: Intelligent qubit allocation and index analysis
- **Multi-platform Support**: Works on Linux, macOS, and Windows with appropriate LLVM installations

## Architecture

The transformation pass converts C quantum intrinsics into QIR runtime calls:

```
C Code with qc_* calls → LLVM IR → C-to-QIR Pass → QIR-compatible IR
```

### Supported Quantum Operations

| C Intrinsic | QIR Runtime Call | Description |
|-------------|------------------|-------------|
| `qc_h(state, n, idx)` | `__quantum__qis__h__body` | Hadamard gate |
| `qc_x(state, n, idx)` | `__quantum__qis__x__body` | Pauli-X gate |
| `qc_cnot(state, n, ctrl, tgt)` | `__quantum__qis__x__ctl` | Controlled-X gate |
| `qc_measure(state, n, idx)` | `__quantum__qis__mz__body` | Z-basis measurement |

## Requirements

### System Requirements
- **LLVM**: Version 12 or higher (tested with LLVM 15-17)
- **Clang**: Compatible version with your LLVM installation
- **CMake**: Version 3.16 or higher
- **C++ Compiler**: Supporting C++14 or higher

### Platform-Specific Requirements

#### Linux
```bash
# Ubuntu/Debian
sudo apt install llvm-dev clang cmake build-essential

# Fedora/RHEL
sudo dnf install llvm-devel clang cmake gcc-c++
```

#### macOS
```bash
# Using Homebrew
brew install llvm cmake

# Using MacPorts
sudo port install llvm-15 +universal cmake
```

#### Windows
- Install LLVM from the official releases
- Visual Studio 2019 or higher with C++ tools
- CMake (available through Visual Studio installer)

## Installation

1. **Clone the repository**:
```bash
git clone https://github.com/feelerx/C_qir.git
cd C_qir
```

2. **Create build directory**:
```bash
mkdir build && cd build
```

3. **Configure with CMake**:
```bash
# Linux/macOS with system LLVM
cmake .. -DLLVM_DIR=$(llvm-config --cmakedir)

# macOS with Homebrew LLVM
cmake .. -DLLVM_DIR=$(brew --prefix llvm)/lib/cmake/llvm

# Custom LLVM installation
cmake .. -DLLVM_DIR=/path/to/llvm/lib/cmake/llvm
```

4. **Build the pass**:
```bash
make
```

## Usage

### Basic Workflow

1. **Write your quantum program in C**:
```c
#include <stdio.h>

// Quantum intrinsic declarations
void qc_h(void *state, int num_qubits, int idx);
void qc_x(void *state, int num_qubits, int idx);
void qc_cnot(void *state, int num_qubits, int control, int target);
int qc_measure(void *state, int num_qubits, int idx);

int main() {
    int num_qubits = 3;
    void *state = 0; // Placeholder - ignored by pass

    // Create Bell state
    qc_h(state, num_qubits, 0);        // |0⟩ → |+⟩
    qc_cnot(state, num_qubits, 0, 1);  // Entangle qubits 0 and 1
    
    // Measure both qubits
    int m0 = qc_measure(state, num_qubits, 0);
    int m1 = qc_measure(state, num_qubits, 1);
    
    printf("Measurements: %d, %d\n", m0, m1);
    return 0;
}
```

2. **Compile C to LLVM IR**:
```bash
# Linux/Windows
clang -O0 -emit-llvm -S ./program.c -o program.ll

# macOS
clang -O0 -emit-llvm -S ./program.c -o program.ll --sysroot $(xcrun --show-sdk-path)
```

3. **Apply the C-to-QIR transformation**:
```bash
# Linux
opt -load-pass-plugin ./build/libCToQIRPass.so -passes="c-to-qir" program.ll -S -o program_qir.ll

# macOS
opt -load-pass-plugin ./build/libCToQIRPass.dylib -passes="c-to-qir" program.ll -S -o program_qir.ll

# Windows
opt -load-pass-plugin ./build/CToQIRPass.dll -passes="c-to-qir" program.ll -S -o program_qir.ll
```

4. **View the generated QIR**:
```bash
cat program_qir.ll
```

### Advanced Usage

#### Custom Qubit Count Detection
The pass automatically detects the number of qubits by analyzing:
1. Store instructions with constant values
2. Function arguments
3. Maximum qubit indices used in operations

#### Runtime Integration
The generated QIR can be linked with:
- Microsoft QIR Runtime
- Custom QIR-compatible runtimes
- Transpiled to Qiskit, Cirq, or other frameworks

#### Optimization Pipeline
```bash
# Apply additional LLVM optimizations
opt -load-pass-plugin ./build/libCToQIRPass.so \
    -passes="c-to-qir,mem2reg,instcombine" \
    program.ll -S -o program_optimized.ll
```

## Examples

The repository includes several example programs:

- `sample.c`: Basic quantum circuit with H, X, CNOT, and measurement
- `bell_state.c`: Bell state preparation and measurement
- `ghz_state.c`: GHZ state preparation for multiple qubits
- `quantum_walk.c`: Quantum random walk implementation

## Generated QIR Structure

The pass generates QIR that follows Microsoft's specification:

```llvm
; Qubit allocation
%qubits = call %Array* @__quantum__rt__qubit_allocate_array(i64 %num_qubits)

; Single-qubit operations
call void @__quantum__qis__h__body(%Qubit* %qubit0)
call void @__quantum__qis__x__body(%Qubit* %qubit1)

; Two-qubit operations
call void @__quantum__qis__x__ctl(%Array* %controls, %Qubit* %target)

; Measurements
%result = call %Result* @__quantum__qis__mz__body(%Qubit* %qubit)
%bit = call i1 @__quantum__rt__result_equal(%Result* %result, %Result* %one)
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Troubleshooting

### Common Issues

**"Plugin not found" error**:
- Verify LLVM_DIR points to the correct CMake files
- Check that the shared library was built successfully

**"Symbol not found" errors**:
- Ensure LLVM and Clang versions match
- Verify system architecture compatibility

**Runtime linking issues**:
- Make sure QIR runtime libraries are available
- Check library search paths

### Debug Mode
```bash
# Enable verbose output
opt -load-pass-plugin ./build/libCToQIRPass.so -passes="c-to-qir" \
    -debug-only=c-to-qir program.ll -S -o program_qir.ll
```

## Performance Considerations

- The pass performs minimal overhead transformation
- Qubit allocation is optimized for the detected circuit size
- Generated QIR is compatible with existing optimization passes
- Runtime performance depends on the target QIR runtime

## Future Work

- Support for additional quantum gates (RZ, RY, etc.)
- Classical control flow integration
- Quantum error correction primitives
- Direct hardware backend targeting
- Integration with quantum simulators

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Microsoft QIR specification and runtime
- LLVM project for compiler infrastructure
- Quantum computing community for standardization efforts

## Related Publications

*Integrating Quantum Intermediate Representation (QIR) into a C-Based Quantum-Classical Framework for Efficient Quantum Computing* - Research paper describing the theoretical foundation and performance evaluation of this framework.