#include "xcl2.hpp"
#include <vector>
#include <algorithm>
#include <iostream>
#include <iomanip>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/******** SOURCE DATA **********/
#include "data_a.h"
#include "data_a2.h"
#include "data_b.h"
#include "data_b2.h"
#include "data_c.h"
#define MATRIX_A_HEIGHT 4
#define MATRIX_B_WIDTH 64

#define MATRIX_A_WIDTH 30000
#define MATRIX_B_HEIGHT MATRIX_A_WIDTH

#define NUM_REPEAT 10000

/*********** KERNELS ************/
#define NUM_KERNEL 1

// HBM Pseudo-channel(PC) requirements
#define MAX_HBM_PC_COUNT 32
#define PC_NAME(n) n | XCL_MEM_TOPOLOGY
const int pc[MAX_HBM_PC_COUNT+4] = {
    PC_NAME(0),  PC_NAME(1),  PC_NAME(2),  PC_NAME(3),  PC_NAME(4),  PC_NAME(5),  PC_NAME(6),  PC_NAME(7),
    PC_NAME(8),  PC_NAME(9),  PC_NAME(10), PC_NAME(11), PC_NAME(12), PC_NAME(13), PC_NAME(14), PC_NAME(15),
    PC_NAME(16), PC_NAME(17), PC_NAME(18), PC_NAME(19), PC_NAME(20), PC_NAME(21), PC_NAME(22), PC_NAME(23),
    PC_NAME(24), PC_NAME(25), PC_NAME(26), PC_NAME(27), PC_NAME(28), PC_NAME(29), PC_NAME(30), PC_NAME(31),
    PC_NAME(32), PC_NAME(33), PC_NAME(34), PC_NAME(35)};


/******* FLOAT16 CONVERSION *********/
void float32(float *__restrict out, const uint16_t in) {
    uint32_t t1;
    uint32_t t2;
    uint32_t t3;

    t1 = in & 0x7fffu;                       // Non-sign bits
    t2 = in & 0x8000u;                       // Sign bit
    t3 = in & 0x7c00u;                       // Exponent

    t1 <<= 13u;                              // Align mantissa on MSB
    t2 <<= 16u;                              // Shift sign bit into position

    t1 += 0x38000000;                       // Adjust bias

    t1 = (t3 == 0 ? 0 : t1);                // Denormals-as-zero

    t1 |= t2;                               // Re-insert sign bit

    *((uint32_t *) out) = t1;
};

cl::Context generateContext() {
    cl::Context context;
    return context;
}

cl::CommandQueue generateQueue() {
    cl::CommandQueue q;
    return q;
}

cl::Kernel generateKernel() {
    cl::Kernel krnl;
    return krnl;
}

void programDevice(std::string binaryFile, cl::CommandQueue& q, cl::Context& context, cl::Kernel& krnl) {

    cl_int err;

    //--- Program Device ---
    auto devices = xcl::get_xil_devices();
    auto fileBuf = xcl::read_binary_file(binaryFile);
    cl::Program::Binaries bins{{fileBuf.data(), fileBuf.size()}};
    bool valid_device = false;
    for(size_t i=0; i<devices.size(); i++){
        auto device = devices[i];
        OCL_CHECK(err, context = cl::Context(device, nullptr, nullptr, nullptr, &err));
        OCL_CHECK(err, q = cl::CommandQueue(context, device, CL_QUEUE_PROFILING_ENABLE, &err));

        std::cout << "...TRYING TO PROGRAM DEVICE[" << i << "]: " << device.getInfo<CL_DEVICE_NAME>() << std::endl;
        cl::Program program(context, {device}, bins, nullptr, &err);
        if(err != CL_SUCCESS) {
            std::cout << "Failed to program device[" << i << "] with xclbin file ! \n";
        } else {
            std::cout << "...PROGRAM SUCCESS: device[" << i << "]\n";
            OCL_CHECK(err, krnl = cl::Kernel(program, "krnl_vadd_rtl", &err));
            valid_device = true;
            break;
        }
    }

    if(!valid_device) {
        std::cout << "Failed to program any device... \n";
        exit(EXIT_FAILURE);
    }
}

cl::Buffer* moveMatA(cl::CommandQueue& q, cl::Context& context, size_t matrix_a_width, uint16_t* data){
    cl_int err;

    //--- Data -----------
    std::vector<uint32_t, aligned_allocator<uint32_t> >* source_plram{ new std::vector<uint32_t, aligned_allocator<uint32_t> >[MATRIX_A_HEIGHT/2]};

    for(size_t i=0; i<MATRIX_A_HEIGHT/2; i++) {
        source_plram[i].resize(matrix_a_width);
    }


    cl_mem_ext_ptr_t inBufExt_plram[MATRIX_A_HEIGHT/2];
    cl::Buffer* buffer_input_plram{ new cl::Buffer[MATRIX_A_HEIGHT/2]};

    for(size_t i=0; i<MATRIX_A_HEIGHT/2; i++){
        inBufExt_plram[i].obj = source_plram[i].data();
        inBufExt_plram[i].param = 0;
        inBufExt_plram[i].flags = pc[i+34];
        OCL_CHECK(err, 
                buffer_input_plram[i] = cl::Buffer(context, 
                                        CL_MEM_READ_ONLY | CL_MEM_EXT_PTR_XILINX | CL_MEM_USE_HOST_PTR,
                                        sizeof(uint32_t) * matrix_a_width, &inBufExt_plram[i], &err));                                   
    
    }

    //--- SET HOST DATA -------------------------------------------------
    //--- Matrix Data 
    for(size_t i=0; i<MATRIX_A_HEIGHT/2; i++){
        for(size_t j=0; j<matrix_a_width; j++){
            source_plram[i][j] = (data[(2*i+1)*matrix_a_width + j] << 16) + (data[2*i*matrix_a_width + j]);
        }
    }

    //--- Send Data to FPGA's memory (Host -> FPGA)-----------------------
    for(size_t i=0; i<MATRIX_A_HEIGHT/2; i++){
        err = q.enqueueMigrateMemObjects({
            buffer_input_plram[i]
        }, 0);
    }
    q.finish();

    return buffer_input_plram;
}


cl::Buffer* moveMatB(cl::CommandQueue& q, cl::Context& context, size_t matrix_b_height, uint16_t* data){
    cl_int err;

    //--- Data -----------
    std::vector<uint32_t, aligned_allocator<uint32_t> >* source_hbm{ new std::vector<uint32_t, aligned_allocator<uint32_t> >[MATRIX_B_WIDTH/2] };

    for(size_t i=0; i<MATRIX_B_WIDTH/2; i++){
        source_hbm[i].resize(matrix_b_height);
    }

    cl_mem_ext_ptr_t* inBufExt_hbm{new cl_mem_ext_ptr_t[MATRIX_B_WIDTH/2]};
    cl::Buffer* buffer_input_hbm{ new cl::Buffer[MATRIX_B_WIDTH/2] };

    for(size_t i=0; i<MATRIX_B_WIDTH/2; i++){
        inBufExt_hbm[i].obj = source_hbm[i].data();
        inBufExt_hbm[i].param = 0;
        inBufExt_hbm[i].flags = pc[i];

        OCL_CHECK(err, 
                buffer_input_hbm[i] = cl::Buffer(context, 
                                        CL_MEM_READ_ONLY | CL_MEM_EXT_PTR_XILINX | CL_MEM_USE_HOST_PTR,
                                        sizeof(uint32_t) * matrix_b_height, &inBufExt_hbm[i], &err));
 
    }

    //--- SET HOST DATA -------------------------------------------------
    //--- Matrix Data 
    for(size_t i=0; i<MATRIX_B_WIDTH/2; i++){
        for(size_t j=0; j<matrix_b_height; j++){
            source_hbm[i][j] = (data[j*MATRIX_B_WIDTH + 2*i+1] << 16) + (data[j*MATRIX_B_WIDTH + 2*i]);
        }
    }
    //--- Send Data to FPGA's memory (Host -> FPGA)-----------------------

    for(size_t i=0; i<MATRIX_B_WIDTH/2; i++){
        err = q.enqueueMigrateMemObjects({
            buffer_input_hbm[i]
        }, 0);
    }

    q.finish();
    return buffer_input_hbm;
}

std::vector<uint32_t, aligned_allocator<uint32_t> >* setMatResultHostArr() {
    std::vector<uint32_t, aligned_allocator<uint32_t> >* target_plram{new std::vector<uint32_t, aligned_allocator<uint32_t> >[MATRIX_A_HEIGHT/2]};
    
    return target_plram;
}


cl::Buffer* setMatResultBuffer(cl::Context& context, std::vector<uint32_t, aligned_allocator<uint32_t> >*& target_plram){
    cl_int err;

    for(size_t i=0; i<MATRIX_A_HEIGHT/2; i++) {
        target_plram[i].resize(MATRIX_B_WIDTH);
        std::fill(target_plram[i].begin(), target_plram[i].end(), 0);
    }

    cl_mem_ext_ptr_t outBufExt_plram[MATRIX_A_HEIGHT/2];
    cl::Buffer* buffer_output_plram{new cl::Buffer[MATRIX_A_HEIGHT/2]};
    

    for(size_t i=0; i<MATRIX_A_HEIGHT/2; i++){
        outBufExt_plram[i].obj = target_plram[i].data();
        outBufExt_plram[i].param = 0;
        outBufExt_plram[i].flags = pc[i+34];

        OCL_CHECK(err, 
                buffer_output_plram[i] = cl::Buffer(context, 
                                        CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX | CL_MEM_USE_HOST_PTR,
                                        sizeof(uint32_t) * MATRIX_B_WIDTH, &outBufExt_plram[i], &err));                                       
    }

    return buffer_output_plram;
}

void setArgumentsAndEnqueue(cl::Kernel& krnl, cl::CommandQueue& q, int matrix_a_width, cl::Buffer* buffer_input_plram, cl::Buffer* buffer_input_hbm, cl::Buffer* buffer_output_plram, uint64_t offset, int last, int relu){
    cl_int err;
    

    for(size_t i=0; i<MATRIX_A_HEIGHT/2; i++){
        OCL_CHECK(err, err = krnl.setArg(i, buffer_input_plram[i]));
    }
    for(size_t i=0; i<MATRIX_B_WIDTH/2; i++){
        OCL_CHECK(err, err = krnl.setArg(i+MATRIX_A_HEIGHT/2, buffer_input_hbm[i]));
    }
    for(size_t i=0; i<MATRIX_A_HEIGHT/2; i++){
        OCL_CHECK(err, err = krnl.setArg(i + MATRIX_A_HEIGHT/2 + MATRIX_B_WIDTH/2, buffer_output_plram[i]));
    }
    OCL_CHECK(err, err = krnl.setArg(MATRIX_A_HEIGHT/2 + MATRIX_B_WIDTH/2 + MATRIX_A_HEIGHT/2, (uint64_t)offset));
    OCL_CHECK(err, err = krnl.setArg(MATRIX_A_HEIGHT/2 + MATRIX_B_WIDTH/2 + MATRIX_A_HEIGHT/2 + 1, (int)(matrix_a_width << 2) + (last << 1) + (relu)));


    OCL_CHECK(err, err = q.enqueueTask(krnl));
    return;
}

void getResultMatrix(cl::CommandQueue& q, cl::Buffer* buffer_output_plram, std::vector<uint32_t, aligned_allocator<uint32_t> >*& target_plram){
    cl_int err;

    OCL_CHECK(err, err = q.enqueueMigrateMemObjects({
        buffer_output_plram[0], buffer_output_plram[1]
    }, CL_MIGRATE_MEM_OBJECT_HOST));

    q.finish();

    for(size_t i=0; i<MATRIX_B_WIDTH; i++) {
        float f0;
        float f1;
        float f2;
        float f3;
        float32(&f0, target_plram[0][i]);
        float32(&f1, target_plram[0][i]>>16);
        float32(&f2, target_plram[1][i]);
        float32(&f3, target_plram[1][i]>>16);
        printf("%2d: %7.3f \t%7.3f \t%7.3f \t%7.3f \n", i+1, f0, f1, f2, f3);
    }
    return;
}

int main(int argc, char** argv) {
    std::string binaryFile = argv[1];

    cl::CommandQueue q = generateQueue();
    cl::Context context = generateContext();
    cl::Kernel krnl = generateKernel();

    programDevice(binaryFile, q, context, krnl);

    //--- Data -----------
    cl::Buffer* buffer_input_plram = moveMatA(q, context, MATRIX_A_WIDTH, data_a);
    cl::Buffer* buffer_input_hbm_1 = moveMatB(q, context, MATRIX_B_HEIGHT, data_b);
    cl::Buffer* buffer_input_hbm_2 = moveMatB(q, context, MATRIX_B_WIDTH, data_c);

    std::vector<uint32_t, aligned_allocator<uint32_t> >* target_plram_1 = setMatResultHostArr();
    cl::Buffer* buffer_output_plram_1 = setMatResultBuffer(context, target_plram_1);
    std::vector<uint32_t, aligned_allocator<uint32_t> >* target_plram_2 = setMatResultHostArr();
    cl::Buffer* buffer_output_plram_2 = setMatResultBuffer(context, target_plram_2);

    //--- SET HOST DATA -------------------------------------------------


    std::chrono::duration<double> kernel_time(0);
    auto kernel_start = std::chrono::high_resolution_clock::now();
    for(int i=0; i<NUM_REPEAT; i++){
        setArgumentsAndEnqueue(krnl, q, MATRIX_A_WIDTH, buffer_input_plram, buffer_input_hbm_1, buffer_output_plram_1, 0, i==NUM_REPEAT-1, 0);
    }
    q.finish();
    auto kernel_end = std::chrono::high_resolution_clock::now();
    kernel_time = std::chrono::duration<double>(kernel_end - kernel_start);

    setArgumentsAndEnqueue(krnl, q, MATRIX_B_WIDTH, buffer_output_plram_1, buffer_input_hbm_2, buffer_output_plram_2, 0, 1, 0);


    double kernel_time_in_sec = kernel_time.count();

    getResultMatrix(q, buffer_output_plram_1, target_plram_1);
    getResultMatrix(q, buffer_output_plram_2, target_plram_2);

    double ratio = (double)((MATRIX_A_WIDTH + MATRIX_B_WIDTH) * NUM_REPEAT)*34*4;
    double bandwidth = ratio / kernel_time_in_sec / 1000/1000/1000;

    std::cout << "\n[Test Info]" << std::endl;
    std::cout << "Matrix A: " << MATRIX_A_HEIGHT << " x " << MATRIX_A_WIDTH << std::endl;
    std::cout << "Matrix B: " << MATRIX_B_HEIGHT << " x " << MATRIX_B_WIDTH << std::endl;
    std::cout << "Matrix C: " << MATRIX_B_WIDTH << " x " << 64 << std::endl;
    std::cout << "Number of Repeats: " << NUM_REPEAT << std::endl;

    std::cout << "\nBandwidth: " << bandwidth << "GB/s" << std::endl;
    std::cout << "\nTEST FINISHED\n" << std::endl;

    return EXIT_SUCCESS;

}