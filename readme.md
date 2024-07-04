# SYSTOLIC ARRAY

This is a verilog implementation of systolic array multiplier. This implementation can generate systolic array multipliers with arbitrary number of processing elements(PE) in both horizontal and vertical directions. Furthermore, it can compose multiple smaller systolic arrays to make them act as a bigger systolic array

## Implementation

### NDP_unit

NDP_unit accepts two matrices' values and operated matrix multiplication on them. 
1. To start its calculation, the module's registers must be intialized to 0 by setting reset signal to 1. 
2. First matrix's values are fed into NDP unit through in_a in column by column order. At the same time, second matrix's values are fed into NDP unit through in_b in row by row order. 
3. When all values of the matrices are fed into NDP_unit, in_done_flag is set to 1 to notify the module that all data is transfered.

NDP_unit can be composed in arbitrary sizes. The number of systolic arrays that compose the unit can be set arbitrarily as well as the the number of PEs that make up each systolic array.

Parameter  | Description
----------- | -------------
WIDTH | Data width (e.g. 16 for float16)
ARR_WIDTH | # of processing elements in a systolic array (horizontal direction)
ARR_HEIGHT | # of processing elements in a systolic array (vertical direction)
SYS_WIDTH | # of systolic arrays to work together (horizontal direction)
SYS_HEIGHT | # of systolic arrays to work together (vertical direction)

<img src= "https://github.com/bloominho/systolic_array/blob/main/pic/SYS_ARRAY.png">


To compute matrix multiplication, data from each matrices should be fed into systolic arrays in different timings. This is handled by using triangular shaped buffers.

<img src= "https://github.com/bloominho/systolic_array/blob/main/pic/Systolic_Array_Buffer.png">


### systolic_array_align

Arbitrary number of systolic arrays compose this module to act as a single large systolic array. The number of systolic arrays are set from NDP_unit module (parameters SYS_WIDTH and SYS_HEIGHT).

Data are passes within arrays using v_passes and h_passes net.

<img src= "https://github.com/bloominho/systolic_array/blob/main/pic/systolic_array_dataflow.png">

### systolic_array

Arbitrary number of processing elements are composed in this module. The number of processing elements that make up each systolic array is set using parameters ARR_HEIGHT and ARR_WIDTH from NDP_unit module. 

Just like systolic_array_align, data from each processing element is passes through v_passes and h_passes net.

### processing_element

A processing element receives two inputs, in_a and in_b, each from west and north. The element multiplies the two values. The multiplied result is accumulated at out_c.

At each clock edge, the values from in_a and in_b is passes out each through out_a and out_b ports. These values are passed to next processing element in eastern and southern direction.


## Usage
> *NDP_unit is top module.

1. Set reset to 1
2. Set reset to 0, feed the module **in_a: columns of matrix A, in_b: rows of matrix B** each clock.
3. Set in_done_flag to 1
4. wait until calc_done_flag = 1.
5. read the results from out_c

## Simulation Results

### Test vector generation
Test vector is generated from generate_int.py.

Parameter  | Description
----------- | -------------
iteration | number of test samples to generate
A_HEIGHT | Height of matrix A
A_WIDTH | Width of matrix A
B_HEIGHT | Height of matrix B
B_WIDTH | Width of matrix B

Generated matrices A and B, expected results R are saved at TestVectorA, TestVectorB, TestVectorR.

### Results

Simulation is done with tb_sys_array.v

Simulation Settings:
Parameter  | Value
----------- | -------------
Size of Matrix A | 4x3
Size of Matrix B | 3x256
WIDTH | 16
ARR_WIDTH | 4
ARR_HEIGHT | 4
SYS_WIDTH | 64
SYS_HEIGHT | 1

For 300 samples, the results were verified correct.