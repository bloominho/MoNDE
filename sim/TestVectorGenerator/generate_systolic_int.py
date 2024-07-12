import bitstring, random
import numpy as np

# --- Number of Simulations ---
iteration = 100

# --- Matrix Size ---
A_HEIGHT = 4
A_WIDTH = 3
B_HEIGHT = A_WIDTH
B_WIDTH = 256

# --- Integer to Binary(16b) ---
def bit(int):
    b = bitstring.BitStream(int=int, length=16)
    return b.bin

def main():
    with open("TestVectorA", "w") as fA:
        with open("TestVectorB", "w") as fB:
            with open("TestVectorR", "w") as fC:
                for i in range(iteration):
                    # Generate Matrix
                    A = np.random.randint(low=0, high=100, size=(A_HEIGHT, A_WIDTH), dtype=np.uint16)
                    B = np.random.randint(low=0, high=100, size=(B_HEIGHT, B_WIDTH), dtype=np.uint16)

                    # Calculate MatMul
                    C = A @ B

                    # Write matrix A (in Vertical First order), B, C
                    for a in A.T.flat:
                        fA.write(str(bit(a)))

                    for b in B.flat:
                        fB.write(str(bit(b)))

                    for c in C.flat:
                        fC.write(str(bit(c)))

                    # Next line for next matrix
                    fA.write("\n")
                    fB.write("\n")
                    fC.write("\n")

if __name__ == "__main__":
    main()