import numpy as np
import struct

# --- Number of Simulations ---
iteration = 100
span = 2.0

# --- Matrix Size ---
A_HEIGHT = 4
A_WIDTH = 30000
B_HEIGHT = A_WIDTH
B_WIDTH = 64

C_HEIGHT = B_WIDTH
C_WIDTH = B_WIDTH


# --- Convert float -> binary ---
def bit(flt):
    bits, = struct.unpack('!H', struct.pack('!e', flt))
    return hex(int("{:016b}".format(bits), 2))


# --- Matrix Multiplication ---
def matmul(A, B, I, J, K):
    C = np.empty(I * K, dtype=np.float16)
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
    np.random.seed(0)
    # Generate Matrix A, B
    A = np.random.randn(A_HEIGHT, A_WIDTH).astype(np.float16)
    A2 = np.random.randn(A_HEIGHT, A_WIDTH).astype(np.float16)
    B = np.random.randn(B_HEIGHT, B_WIDTH).astype(np.float16)
    B2 = np.random.randn(B_HEIGHT, B_WIDTH).astype(np.float16)
    C = np.random.randn(C_HEIGHT, C_WIDTH).astype(np.float16)


    # Matrix Multiplication
    D = np.matmul(A, B, dtype=np.float16)
    D2 = np.matmul(A, B2, dtype=np.float16)

    E = np.matmul(D, C, dtype=np.float16)

    with (open("data_a.h", "w") as fa):
        fa.write("uint16_t data_a[" + str(A_WIDTH * A_HEIGHT) + "] = {")
        for i in range(A_HEIGHT):
            for j in range(A_WIDTH):
                fa.write(str(bit(A[i, j])))
                if(j == A_WIDTH - 1 and i == A_HEIGHT -1) :
                    fa.write("};")
                else:
                    fa.write(",\n")

    with (open("data_a2.h", "w") as fa):
        fa.write("uint16_t data_a2[" + str(A_WIDTH * A_HEIGHT) + "] = {")
        for i in range(A_HEIGHT):
            for j in range(A_WIDTH):
                fa.write(str(bit(A2[i, j])))
                if(j == A_WIDTH - 1 and i == A_HEIGHT -1) :
                    fa.write("};")
                else:
                    fa.write(",\n")
    
    with (open("data_b.h", "w") as fb):
        fb.write("uint16_t data_b[" + str(B_HEIGHT * B_WIDTH) + "] = {")
        for i in range(B_HEIGHT):
            for j in range(B_WIDTH):
                fb.write(str(bit(B[i, j])))
                if j == B_WIDTH - 1 and i == B_HEIGHT -1 :
                    fb.write("};")
                else:
                    fb.write(",\n")
    
    with (open("data_b2.h", "w") as fb):
        fb.write("uint16_t data_b2[" + str(B_HEIGHT * B_WIDTH) + "] = {")
        for i in range(B_HEIGHT):
            for j in range(B_WIDTH):
                fb.write(str(bit(B2[i, j])))
                if j == B_WIDTH - 1 and i == B_HEIGHT -1 :
                    fb.write("};")
                else:
                    fb.write(",\n")

    with (open("data_c.h", "w") as fc):
        fc.write("uint16_t data_c[" + str(C_HEIGHT * C_WIDTH) + "] = {")
        for i in range(C_HEIGHT):
            for j in range(C_WIDTH):
                fc.write(str(bit(C[i, j])))
                if j == C_WIDTH - 1 and i == C_HEIGHT -1 :
                    fc.write("};")
                else:
                    fc.write(",\n")

    with (open("data_result1.h", "w") as f3):
        f3.write("uint16_t data_result1["+ str(A_HEIGHT*B_WIDTH)+"] = {")
        for i in range(A_HEIGHT):
            for j in range(B_WIDTH):
                f3.write(str(bit(D[i, j])))
                if j == B_WIDTH-1 and i == A_HEIGHT - 1 :
                    f3.write("};")
                else:
                    f3.write(",\n")

    with (open("data_result1_plain.h", "w") as f3):
        f3.write("uint16_t data_result1[" + str(A_HEIGHT * B_WIDTH) + "] = {")
        for i in range(A_HEIGHT):
            for j in range(B_WIDTH):
                f3.write(str(D[i, j]))
                if j == B_WIDTH - 1 and i == A_HEIGHT - 1:
                    f3.write("};")
                else:
                    f3.write(",\n")

    with (open("data_result1_2.h", "w") as f3):
        f3.write("uint16_t data_result1["+ str(A_HEIGHT*B_WIDTH)+"] = {")
        for i in range(A_HEIGHT):
            for j in range(B_WIDTH):
                f3.write(str(bit(D2[i, j])))
                if j == B_WIDTH-1 and i == A_HEIGHT - 1 :
                    f3.write("};")
                else:
                    f3.write(",\n")

    with (open("data_result1_2_plain.h", "w") as f3):
        f3.write("uint16_t data_result1[" + str(A_HEIGHT * B_WIDTH) + "] = {")
        for i in range(A_HEIGHT):
            for j in range(B_WIDTH):
                f3.write(str(D2[i, j]))
                if j == B_WIDTH - 1 and i == A_HEIGHT - 1:
                    f3.write("};")
                else:
                    f3.write(",\n")

    with (open("data_result2.h", "w") as f3):
        f3.write("uint16_t data_result2["+ str(A_HEIGHT*B_WIDTH)+"] = {")
        for i in range(A_HEIGHT):
            for j in range(B_WIDTH):
                f3.write(str(bit(E[i, j])))
                if j == B_WIDTH-1 and i == A_HEIGHT - 1 :
                    f3.write("};")
                else:
                    f3.write(",\n")

    with (open("data_result2_plain.h", "w") as f3):
        f3.write("uint16_t data_result2[" + str(A_HEIGHT * B_WIDTH) + "] = {")
        for i in range(A_HEIGHT):
            for j in range(B_WIDTH):
                f3.write(str(E[i, j]))
                if j == B_WIDTH - 1 and i == A_HEIGHT - 1:
                    f3.write("};")
                else:
                    f3.write(",\n")


if __name__ == "__main__":
    main()