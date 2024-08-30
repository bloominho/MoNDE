#include <pybind11/pybind11.h>
#include <pybind11/numpy.h>
namespace py = pybind11;

#include "xcl2.hpp"
#include <vector>
#include <algorithm>
#include <iostream>
#include <iomanip>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/*********** NDP SIZE ************/
#define MATRIX_A_HEIGHT 4
#define MATRIX_B_WIDTH 64

/*********** KERNELS ************/
#define NUM_KERNEL 1
#define MAX_HBM_PC_COUNT 32
#define PC_NAME(n) n | XCL_MEM_TOPOLOGY
const int pc[MAX_HBM_PC_COUNT+4] = {
    PC_NAME(0),  PC_NAME(1),  PC_NAME(2),  PC_NAME(3),  PC_NAME(4),  PC_NAME(5),  PC_NAME(6),  PC_NAME(7),
    PC_NAME(8),  PC_NAME(9),  PC_NAME(10), PC_NAME(11), PC_NAME(12), PC_NAME(13), PC_NAME(14), PC_NAME(15),
    PC_NAME(16), PC_NAME(17), PC_NAME(18), PC_NAME(19), PC_NAME(20), PC_NAME(21), PC_NAME(22), PC_NAME(23),
    PC_NAME(24), PC_NAME(25), PC_NAME(26), PC_NAME(27), PC_NAME(28), PC_NAME(29), PC_NAME(30), PC_NAME(31),
    PC_NAME(32), PC_NAME(33), PC_NAME(34), PC_NAME(35)};



//---- PYBIND WRAPPER ----------------------------------------------
struct ContextWrapper {
    ContextWrapper(cl::Context c) : context(c) {}
    cl::Context context;
};
struct CommandQueueWrapper {
    CommandQueueWrapper(cl::CommandQueue q) : commandQueue(q) {}
    cl::CommandQueue commandQueue;
};
struct KernelWrapper {
    KernelWrapper(cl::Kernel k) : kernel(k) {}
    cl::Kernel kernel;
};
struct BufferWrapper {
    BufferWrapper(cl::Buffer* b) : buffer(b) {}
    cl::Buffer* buffer;
};
struct VectorOfArrayWrapper {
    VectorOfArrayWrapper(std::vector<uint32_t, aligned_allocator<uint32_t> >* v) : vector(v) {}
    std::vector<uint32_t, aligned_allocator<uint32_t> >* vector;
};



//---- FUNCTIONS -----------------------------------------------

//---- Generate Context ------------------
ContextWrapper generateContext() {
    cl::Context context;
    ContextWrapper contextWrapped= *(new ContextWrapper(context));
    return contextWrapped;
}

//---- Generate Command Queue ------------------
CommandQueueWrapper generateQueue() {
    cl::CommandQueue q;
    CommandQueueWrapper queueWrapped= *(new CommandQueueWrapper(q));
    return queueWrapped;
}

//---- Generate Kernel ------------------
KernelWrapper generateKernel() {
    cl::Kernel krnl;
    KernelWrapper kernelWrapped= *(new KernelWrapper(krnl));
    return kernelWrapped;
}

//---- Program Device ----------------------
void programDevice(CommandQueueWrapper& q_wrapper, 
                    ContextWrapper& context_wrapper, 
                    KernelWrapper& krnl_wrapper) {
    std::string binaryFile = "./vadd.xclbin";
    cl_int err;

    //--- Unwrap Pybind Wrappers ---------------------
    cl::Context* context = &(context_wrapper.context);
    cl::CommandQueue* q = &(q_wrapper.commandQueue);
    cl::Kernel* krnl = &(krnl_wrapper.kernel);

    //--- Program Device -----------------------------
    auto devices = xcl::get_xil_devices();
    auto fileBuf = xcl::read_binary_file(binaryFile);
    cl::Program::Binaries bins{{fileBuf.data(), fileBuf.size()}};
    bool valid_device = false;
    for(size_t i=0; i<devices.size(); i++){
        auto device = devices[i];
        OCL_CHECK(err, *context = cl::Context(device, nullptr, nullptr, nullptr, &err));
        OCL_CHECK(err, *q = cl::CommandQueue(*context, device, CL_QUEUE_PROFILING_ENABLE, &err));

        std::cout << "...Trying to program DEVICE[" << i << "]: " << device.getInfo<CL_DEVICE_NAME>() << std::endl;
        cl::Program program(*context, {device}, bins, nullptr, &err);
        if(err != CL_SUCCESS) {
            std::cout << "Failed to program device[" << i << "] with xclbin file ! \n";
        } else {
            std::cout << "...Programmed Successfully: device[" << i << "]\n";
            OCL_CHECK(err, *krnl = cl::Kernel(program, "krnl_vadd_rtl", &err));
            valid_device = true;
            break;
        }
    }

    if(!valid_device) {
        std::cout << "Failed to program any device... \n";
        exit(EXIT_FAILURE);
    }
}

BufferWrapper moveMatA(CommandQueueWrapper& q_wrapper, ContextWrapper& context_wrapper, py::array py_data){
    cl_int err;

    cl::CommandQueue q = q_wrapper.commandQueue;
    cl::Context context = context_wrapper.context;

    auto matrix_a_buf = py_data.request();
    int matrix_a_width = matrix_a_buf.shape[1];
    uint16_t* data = static_cast<uint16_t*>(matrix_a_buf.ptr);

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

    
    BufferWrapper buffer_input_plram_wrapped = *(new BufferWrapper(buffer_input_plram));
    
    return buffer_input_plram_wrapped;
}

BufferWrapper moveMatB(CommandQueueWrapper& q_wrapper, ContextWrapper& context_wrapper, py::array py_data){

    cl::CommandQueue q = q_wrapper.commandQueue;
    cl::Context context = context_wrapper.context;

    auto matrix_b_buf = py_data.request();
    int matrix_b_height = matrix_b_buf.shape[0];
    uint16_t* data = static_cast<uint16_t*>(matrix_b_buf.ptr);
    
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


    BufferWrapper buffer_input_hbm_wrapped = *(new BufferWrapper(buffer_input_hbm));

    return buffer_input_hbm_wrapped;
}

VectorOfArrayWrapper setMatResultHostArr() {
    std::vector<uint32_t, aligned_allocator<uint32_t> >* target_plram{new std::vector<uint32_t, aligned_allocator<uint32_t> >[MATRIX_A_HEIGHT/2]};
    
    
    VectorOfArrayWrapper v = *(new VectorOfArrayWrapper(target_plram));
    return v;
}


BufferWrapper setMatResultBuffer(ContextWrapper& context_wrapper, VectorOfArrayWrapper& v_target_plram, int count){
    cl_int err;

    cl::Context context = context_wrapper.context;

    std::vector<uint32_t, aligned_allocator<uint32_t> >* target_plram = v_target_plram.vector;
    for(size_t i=0; i<MATRIX_A_HEIGHT/2; i++) {
        target_plram[i].resize(MATRIX_B_WIDTH*count);
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
                                        sizeof(uint32_t) * MATRIX_B_WIDTH*count, &outBufExt_plram[i], &err));                                       
    }


    BufferWrapper buffer_output_plram_wrapped = *(new BufferWrapper(buffer_output_plram));
    return buffer_output_plram_wrapped;
}

void freeBuffer(BufferWrapper buffer_output_plram_wrapped){
    cl::Buffer* buffer_output_plram = buffer_output_plram_wrapped.buffer;

    for(size_t i=0; i<MATRIX_A_HEIGHT/2; i++){
        buffer_output_plram[i] = nullptr;
    }

    return;
}

void setArgumentsAndEnqueue(KernelWrapper& krnl_wrapper, CommandQueueWrapper& q_wrapper, int matrix_a_width, BufferWrapper buffer_input_plram_wrapped, BufferWrapper buffer_input_hbm_wrapped, BufferWrapper buffer_output_plram_wrapped, uint64_t offset, int last, int relu){
    cl_int err;

    cl::Kernel krnl = krnl_wrapper.kernel;
    cl::CommandQueue q = q_wrapper.commandQueue;

    cl::Buffer* buffer_input_plram = buffer_input_plram_wrapped.buffer;
    cl::Buffer* buffer_input_hbm = buffer_input_hbm_wrapped.buffer;
    cl::Buffer* buffer_output_plram = buffer_output_plram_wrapped.buffer;

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
    if(last == 1){
        q.finish();
    }
    return;
}

py::array getResultMatrix(CommandQueueWrapper& q_wrapper, BufferWrapper buffer_output_plram_wrapped, VectorOfArrayWrapper& v_target_plram, py::array py_reference_array, int length){
    cl_int err;

    cl::CommandQueue& q = q_wrapper.commandQueue;
    cl::Buffer* buffer_output_plram = buffer_output_plram_wrapped.buffer;
    std::vector<uint32_t, aligned_allocator<uint32_t> >* target_plram = v_target_plram.vector;

    OCL_CHECK(err, err = q.enqueueMigrateMemObjects({
        buffer_output_plram[0], buffer_output_plram[1]
    }, CL_MIGRATE_MEM_OBJECT_HOST));

    q.finish();


    //--- Read Reference Array --------
    auto reference_array = py_reference_array.request();
    //--- Generate Result Numpy Array ----
    auto result_array = py::array(py::buffer_info(
        nullptr,
        sizeof(uint16_t),
        reference_array.format,
        2,
        {MATRIX_A_HEIGHT, length},
        {sizeof(uint16_t)*length, sizeof(uint16_t)}
    ));
    auto result_array_buffer = result_array.request();
    uint16_t *result_array_ptr = static_cast<uint16_t*>(result_array_buffer.ptr);

    for(size_t i=0; i<length; i++) {
        result_array_ptr[0*length + i] = target_plram[0][i];
        result_array_ptr[1*length + i] = target_plram[0][i] >> 16;
        result_array_ptr[2*length + i] = target_plram[1][i];
        result_array_ptr[3*length + i] = target_plram[1][i] >> 16;
    }

    return result_array;
}

PYBIND11_PLUGIN(matmul_lib) {
    py::module m("matmul_lib");
    py::class_<ContextWrapper>(m, "ContextWrapper");
    py::class_<CommandQueueWrapper>(m, "CommandQueueWrapper");
    py::class_<KernelWrapper>(m, "KernelWrapper");
    py::class_<BufferWrapper>(m, "BufferWrapper");
    py::class_<VectorOfArrayWrapper>(m, "VectorOfArrayWrapper");
    m.def("generateContext", &generateContext, "");
    m.def("generateQueue", &generateQueue, "");
    m.def("generateKernel", &generateKernel, "");
    m.def("programDevice", &programDevice, "");
    m.def("moveMatA", &moveMatA, "");
    m.def("moveMatB", &moveMatB, "");
    m.def("setMatResultHostArr", &setMatResultHostArr, "");
    m.def("setMatResultBuffer", &setMatResultBuffer, "");
    m.def("freeBuffer", &freeBuffer, "");
    m.def("setArgumentsAndEnqueue", &setArgumentsAndEnqueue, "");
    m.def("getResultMatrix", &getResultMatrix, "");
    return m.ptr();
}