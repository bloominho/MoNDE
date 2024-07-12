import bitstring, random
import numpy as np

# --- Number of Simulations ---
iteration = 10000
span = 100

# --- IEEE754 Float Version Size ---
WIDTH = 32
EXP_BITS = 8
FRAC_BITS = 23

# --- Convert Float to ieee754 ---
def bit(flt):
    b = bitstring.BitArray(float=flt, length=16)
    return b

def main():
    with open("TestVectorMulA", "w") as fA:
        with open("TestVectorMulB", "w") as fB:
            with open("TestVectorMulR", "w") as fR:
                for i in range(iteration):
                    # Generate Matrix
                    A = bit(random.uniform(0.0, span))
                    B = bit(random.uniform(0.0, span))
                    R = bit(A.float * B.float)

                    # Write
                    fA.write(str(A.bin))
                    fB.write(str(B.bin))
                    fR.write(str(R.bin))

                    fA.write("\n")
                    fB.write("\n")
                    fR.write("\n")

if __name__ == "__main__":
    main()