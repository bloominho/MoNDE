# MoNDE - Mixture of Near-Data Experts for Large-Scale Sparse Models

> *Mixture-of-Experts (MoE) large language models (LLM) have memory requirements that often exceed the GPU memory capacity, requiring costly parameter movement from secondary memories to the GPU for expert computation. In this work, we present Mixture of Near-Data Experts (MoNDE), a near-data computing solution that efficiently enables MoE LLM inference. MoNDE reduces the volume of MoE parameter movement by transferring only the hot experts to the GPU, while computing the remaining cold experts inside the host memory device. By replacing the transfers of massive expert parameters with the ones of small activations, MoNDE enables far more communication-efficient MoE inference, thereby resulting in substantial speedups over the existing parameter offloading frameworks for both encoder and decoder operations.* - Kim, Taehyun et al. “MoNDE: Mixture of Near-Data Experts for Large-Scale Sparse Models.” (2024)

This is a FPGA implementation of MoNDE. The paper '*MoNDE: Mixture of Near-Data Experts for Large-Scale Sparse Models*' proposes a novel near-data computing solution for accelerating MoE models. MoE models are composed of massive amount of parameters. Because of its massive volume, GPU memory cannot hold the whole set of parameters. As a result GPUs must sequentially bring the parameters from the host's memory to apply calculations. Because of the slow PCIe connections between GPU and host memory, this movement acts as a bottleneck of MoE's inference process. To solve this problem, MoNDE holds a large memory capacity(to store MoE models' gigantic parameters) with compute units. By using compute units that reside inside MoNDE, MoNDE can effectively increase throughput and reduce time required for data transfers. For more detailed explanation, please refer the original paper: [MoNDE: Mixture of Near-Data Experts for Large-Scale Sparse Models.](https://arxiv.org/pdf/2405.18832v1)

## Project Organizations
Folders 1 through 3 are implementation of systolic arrays. These files may include additional modules for memory access, but their functionality is limited to 32 bit width DDR buses, neither does it can support any kind of communication with the host. Folder 4(U280) is the implementation of MoNDE. It includes systolic arrays(from folders 1~3) AND extra modules to communicate with the host, support HBM interconnections, and vice versa. As a result, it can receive data from the host, apply matrix multiplications, and write data memory - it's MoNDE.
1. rtl : RTL implementation for compute units. Note that this version uses Synopsys's floating point adder and multipliers which cannot be synthesized. These must be replaced with synthesizable FP adders and multipliers. *check processing_element.v*
	* 1stage: systolic array. FP adders and multipliers are not pipelined.
	* NDP_1stage: assumes 32 bit AXI4-STREAM data input from the outside of NDP_core, feeded data are temporally stored at scratch_pad(which is composed of brams.)
	* NDP_2stage: assumes 32 bit AXI4-STREAM data input from the outside of NDP_core. FP adders and multipliers are pipelined for 2 stages.
2. sim : simulation files (testbench) for rtl codes. These testbenches work on codes in 'rtl' folder.
	* SystolicTestVector: testvector for '1stage'.
	* SystolicTestVector_NDP_1stage: testvector for 'NDP_1stage'.
	* SystolicTestVector_NDP: testvector for 'NDP_2stage'.
	* testbench: testbench codes. These testbenches are connected to rtl folder, therefore does not require any modification to execute.
	* TestVectorGenerator: Python codes to generate appropriate test vectors for each testbench.
3. synth : synthesizable rtl code. As mentioned above, codes in 'rtl' folder uses floating point adders and multipliers that are not synthesizable (only for simulation purposes). These files are replaced with AMD's vivado floating-point core IPs. Other vivado IPs like BRAM are used. On top of this, control modules(e.g. DMA) that read matrix data from memory is implemented.
	* 1stage: rtl codes for synth, 1stage floating point units are used.
	* 2stage: rtl codes for synth, 2 stage pipelined floating point units are used.
	* vivado: vivado project files. The project files imports rtl codes in 1stage/2stage folder.
4. u280: implementation of MoNDE on U280. AMD (Xilinx)'s Alvevo U280 accelerator card supports FPGAs with HBM.
	* common: library for building host program. Includes xcl2.hpp and many more - files for xilinx runtime support.
	* u280_ndp/NDP
		* src
			* krnl_vadd: rtl files are stored here !
				* krnl_vadd_rtl.v: top wrapper file
				* krnl_vadd_rtl_int.sv: top module
				* krnl_vadd_rtl_control_s_axi.v: control slave that communicates with the host. It receives 34 addresses where matrix data are stored, 2 addresses where the results should be stored, and other signals. It also receives when to start its operations and returns a finish signal when all calculations are finished.
				* krnl_vadd_rtl_read_master.sv: reads matrix data from HBM, using addresses passed from control_s_axi
				* NDP_core.sv: systolic array
				* krnl_vadd_rtl_write_master.sv: writes result matrix data to PLRAM, using addresses passes dfrom control_s_axi
			* data_gen.py: generates testvector
			* check_bandwidth.cpp: host file to check the implementation's bandwidth between device memory and systolic array.
			* python_bind.cpp: host file that makes library file(.so) that allows binding for python files. Using the library, a python module can use MoNDE.
		* build_dir.hw.xilinx_u280_gen3x16_xdma_1_202211_1
			* vadd.xclbin: hardware implementation. Bitstream file.
		* Makefile: The top make file. When the folder structure is changed, the makefile must be modifed.
		* makefile_us_alvevo.mk: When U280 is the target, this makefile is ran.
		* krnl_vaddmul.cfg: Connectivity information. It connects AXI ports to each HBM/PLRAM pseudo channels.
		* xrt.ini: debug(hw_emu) configurations.
		* matmul_lib.so: library file. This file is used for python bindings.
		* rtl_vadd: host file. This file is used for bandwidth testings.
5. switch_transformers: Switch Transformer model that is revised to use MoNDE.
	* modeling_switch_transformers.py: Switch Transformer source. Some parts are edited to use MoNDE. For places that were edited, find "EDITED" comment tags.
	* matmul_verify.py: a simple python script that tests python matrix multiplication using MoNDE.
	* switch_transformer_verify.py: Python script that runs a summerization task MoE model using MoNDE.
	* vadd.xclbin: vadd.xclvin file must be moved here from folder 4 when new implementations are built.
	* matmul_lib.so: matmul_lib.so file must be moved here from folder 4 when new implementations are built.

The images in 'pic' folder may help you understand how U280 implementation works.

## To Build U280 Implementation


### 1. Build MoNDE
First, we have to make rtl files into U280 FPGA implementation. Follow these steps to build.
1. Put all rtl files in u280/u280_ndp/NDP/src/krnl_vadd/hdl
2. Your terminal should be at the folder where the makefile is.
3. run the command "make build TARGET=hw PLATFORM=${U280_PLATFORM}"

When it fails, try checking Makefile. See if all locations are written correctly - especially when you changed the structure of this project file (e.g. changed folders' names).

The generated file will be located at build_dir.hw.xilinx_u280P.... folder as 'vadd.xclbin'.

### 2. Build Host program (stand-alone program)
The Host program must send matrix data to U280 and signal the MoNDE to start executing. This is done with a host program. To build the host program, follow these steps.

1. The source code for this host program is check_bandwidth.cpp. If you need to modify its functions, go ahead and edit this file. Current implementation uses three header files - data_a.h, data_b.h, data_c.h - for test data.
2. When you're ready to build the host program, run the command "make host TARGET=hw PLATFORM=${U280_PLATFORM}".

The host program will be generated as 'rtl_vadd'.

Note that there are some numbers defined at check_bandwidth.cpp. These numbers indicated the size of test matrices. When you want to use different sizes, simply edit these numbers. Remember to make new test data and connect it just like data_a.h, data_b.h, and data_c.h.

### 3. Run stand-alone host program.

When your implementation and host program is built, you can now run them. Simply run "make test TARGET=hw PLATFORM=${U280_PLATFORM}" command. 

### 4. Make Library for pybind.

WHen you want to connect your MoNDE to your python codes, you should build pybind libraries. Run "make python TARGET=hw PLATFORM=${U280_PLATFORM}". Then, import this libary to your python scripts.

## Results

Matrix  | Size
----------- | -------------
A | 4 x 30,000
B | 30,000 x 64
C | 64 x 64

A @ B was executed 10,000 times to check its performance (bandwidth). Then, (A @ B) @ C was executed to check MoNDE's calculation accuracy.

#  | Result
----------- | -------------
Ideal Bandwidth | 18.2104 GB/s
Measured Bandwidth | 17.3943 GB/s

The model achieved 95.5% of ideal bandwidth.

The MoNDE also showed accurated matrix multiplication operations.