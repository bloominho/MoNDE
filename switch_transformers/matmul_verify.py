###################################################
# Verifies matrix multiplication using FPGA       
#
# Result = (A @ B) @ C 
#
# A: 4 x N(free_size)
# B: N(free_size) x 128
# C: 128 x 64
#
###################################################

import matmul_lib
import numpy as np

# ---- Test Data Generation ---------------------
MATRIX_A_HEIGHT = 4
MATRIX_A_WIDTH = 3000

MATRIX_B_HEIGHT = MATRIX_A_WIDTH
MATRIX_B_WIDTH = 128

MATRIX_C_HEIGHT = MATRIX_B_WIDTH
MATRIX_C_WIDTH = 64

mat_A = np.random.normal(0, 0.001, (MATRIX_A_HEIGHT, MATRIX_A_WIDTH)).astype(np.float16)
mat_B = np.random.normal(0, 1, (MATRIX_B_HEIGHT, MATRIX_B_WIDTH)).astype(np.float16)
mat_C = np.random.normal(0, 1, (MATRIX_C_HEIGHT, MATRIX_C_WIDTH)).astype(np.float16)
mat_ref = np.ndarray((0,0), dtype=np.float16)

# ---- Initialize Device ------------------------
q = matmul_lib.generateQueue()
context = matmul_lib.generateContext()
krnl = matmul_lib.generateKernel()
matmul_lib.programDevice(q, context, krnl)

# ---- Set Host Buffer & Move Data to Device ------------------
buffer_input_plram = matmul_lib.moveMatA(q, context, mat_A)
buffer_input_hbm_B_1 = matmul_lib.moveMatB(q, context, np.ascontiguousarray(mat_B[:, :64]))
buffer_input_hbm_B_2 = matmul_lib.moveMatB(q, context, np.ascontiguousarray(mat_B[:, 64:]))
buffer_input_hbm_C = matmul_lib.moveMatB(q, context, mat_C)

#---- Set Result Buffer ---------------------------------------
v_target_plram_1 = matmul_lib.setMatResultHostArr() # Host
buffer_output_plram_1 = matmul_lib.setMatResultBuffer(context, v_target_plram_1, 2)

v_target_plram_2 = matmul_lib.setMatResultHostArr() # FPGA
buffer_output_plram_2 = matmul_lib.setMatResultBuffer(context, v_target_plram_2, 1)

#---- Calculation ---------------------------------------------
#-------- 1. A @ B
matmul_lib.setArgumentsAndEnqueue(krnl, q, MATRIX_A_WIDTH, buffer_input_plram, buffer_input_hbm_B_1, buffer_output_plram_1, 0, 0, 0)
matmul_lib.setArgumentsAndEnqueue(krnl, q, MATRIX_A_WIDTH, buffer_input_plram, buffer_input_hbm_B_2, buffer_output_plram_1, 64*4, 0, 0)
#-------- 2. (A @ B) @ C
matmul_lib.setArgumentsAndEnqueue(krnl, q, MATRIX_B_WIDTH, buffer_output_plram_1, buffer_input_hbm_C, buffer_output_plram_2, 0, 1, 0)

#---- Read results --------------------------------------------
result = matmul_lib.getResultMatrix(q, buffer_output_plram_2, v_target_plram_2, mat_ref, MATRIX_C_WIDTH).T

np_answer = np.matmul(np.matmul(mat_A, mat_B), mat_C).T		# np answer





print("---------------ANSWER---------------")
print(". . . first 5 rows and columns . . .")
print(np_answer[:5, :5])
print("---------------RESULT---------------")
print(". . . first 5 rows and columns . . .")
print(result[:5, :5])

print()
error_matrix = np_answer - result
sum = np.sum(np.diag(error_matrix @ error_matrix.T))
rmse = (sum / np.size(error_matrix))**0.5

print("RMS ERROR: " + str(rmse))
