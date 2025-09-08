#include <stdio.h>

// Forward declarations of simulator intrinsics.
// (These are just dummies for the input — your pass will rewrite them.)
void qc_h(void *state, int num_qubits, int idx);
void qc_x(void *state, int num_qubits, int idx);
void qc_cnot(void *state, int num_qubits, int control, int target);
int  qc_measure(void *state, int num_qubits, int idx);

int main() {
    int num_qubits = 3;
    void *state = 0; // dummy pointer, ignored by pass

    printf("=== Test quantum circuit ===\n");

    // Put qubit 0 into superposition
    qc_h(state, num_qubits, 0);

    // Entangle qubit 0 with qubit 1
    qc_cnot(state, num_qubits, 0, 1);

    // Flip qubit 2
    qc_x(state, num_qubits, 2);

    // Measure all qubits
    for (int i = 0; i < num_qubits; i++) {
        int m = qc_measure(state, num_qubits, i);
        printf("Measurement[%d] = %d\n", i, m);
    }

    return 0;
}