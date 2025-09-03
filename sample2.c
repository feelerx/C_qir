#include <stdio.h>

// Forward declarations of simulator intrinsics.
// (These are just dummies for the input — your pass will rewrite them.)
void qc_h(void *state, int num_qubits, int idx);
void qc_x(void *state, int num_qubits, int idx);
void qc_cnot(void *state, int num_qubits, int control, int target);
int  qc_measure(void *state, int num_qubits, int idx);

int main() {
    int num_qubits = 4;
    void *state = 0; // dummy pointer, ignored by pass

    printf("=== Bell pair + extra gates test ===\n");

    // Create Bell pair between qubits 0 and 1
    qc_h(state, num_qubits, 0);
    qc_cnot(state, num_qubits, 0, 1);

    // Apply X gate to qubit 2
    qc_x(state, num_qubits, 2);

    // Put qubit 3 into superposition and entangle with qubit 2
    qc_h(state, num_qubits, 3);
    qc_cnot(state, num_qubits, 3, 2);

    // Measure all qubits
    for (int i = 0; i < num_qubits; i++) {
        int m = qc_measure(state, num_qubits, i);
        printf("Measurement[%d] = %d\n", i, m);
    }

    return 0;
}
