import numpy as np
import struct

# --- Number of Simulations ---
iteration = 100
span = 2.0

# --- Matrix Size ---
A_HEIGHT = 4
A_WIDTH = 5
B_HEIGHT = A_WIDTH
B_WIDTH = 256


# --- Convert float -> binary ---
def bit(flt):
    bits, = struct.unpack('!H', struct.pack('!e', flt))
    return "{:016b}".format(bits)


# --- Matrix Multiplication ---
def matmul(A, B, I, J, K):
    C = np.empty(A_HEIGHT * B_WIDTH, dtype=np.float16)
    for i in range(I):
        for k in range(K):
            sum1 = np.float16(0.0)
            sum2 = np.float16(0.0)
            for j in range(J-1, -1, -2):
                mul = np.float16(A[i * J + j] * B[j * K + k])
                sum1 = np.float16(sum1 + mul)
            for j in range(J-2, -1, -2):
                mul = np.float16(A[i * J + j] * B[j * K + k])
                sum2 = np.float16(sum2 + mul)
            C[i * K + k] = np.float16(sum1 + sum2)
    return C


def main():
    with (open("TestVectorA", "w") as fA):
        with open("TestVectorB", "w") as fB:
            with open("TestVectorR", "w") as fC:
                for iter in range(iteration):
                    # Generate Matrix A, B
                    A = np.empty(A_HEIGHT * A_WIDTH, dtype=np.float16)
                    for i in range(0, A_HEIGHT * A_WIDTH, 1):
                        A[i:i+1] = np.random.normal(loc=0, scale=1, size=1)

                    B = np.empty(B_HEIGHT * B_WIDTH, dtype=np.float16)
                    for i in range(0, B_HEIGHT * B_WIDTH, 1):
                        B[i:i+1] = np.random.normal(loc=0, scale=1, size=1)

                    # Matrix Multiplication
                    C = matmul(A, B, A_HEIGHT, A_WIDTH, B_WIDTH)

                    # Write matrix A (in Vertical First order), B, C
                    for j in range(A_WIDTH):
                        for i in range(A_HEIGHT):
                            fA.write(str(bit(A[i * A_WIDTH + j])))

                    for i in range(B_HEIGHT):
                        for j in range(B_WIDTH):
                            fB.write(str(bit(B[i * B_WIDTH + j])))

                    for i in range(A_HEIGHT):
                        for j in range(B_WIDTH):
                            fC.write(str(bit(C[i * B_WIDTH + j])))

                    fA.write("\n")
                    fB.write("\n")
                    fC.write("\n")


if __name__ == "__main__":
    main()