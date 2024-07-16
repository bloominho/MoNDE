`timescale 1ns/10ps

`define N_TESTS 100

module tb_NDP_core;
	//---DATA WIDTH---
	parameter WIDTH = 16;

	parameter IS_FLOAT = 1;
	parameter EXP_BITS = 5;
	parameter FRAC_BITS = 10;

	//---# of PE in SYSTOLIC ARRAY---
	parameter ARR_HEIGHT = 4;
	parameter ARR_WIDTH = 4;

	//---# of Systolic Arrays---
	parameter SYS_HEIGHT = 1;
	parameter SYS_WIDTH = 64;

	//---Testbench Data---
	parameter MATRIX_A_HEIGHT = SYS_HEIGHT*ARR_HEIGHT;
	parameter MATRIX_A_WIDTH = 5;
	parameter MATRIX_B_HEIGHT = MATRIX_A_WIDTH;
	parameter MATRIX_B_WIDTH = SYS_WIDTH*ARR_WIDTH;

	reg [MATRIX_A_HEIGHT*MATRIX_A_WIDTH*WIDTH - 1:0] test_A [`N_TESTS - 1:0];	//Matrix A
	reg [MATRIX_B_HEIGHT*MATRIX_B_WIDTH*WIDTH - 1:0] test_B [`N_TESTS - 1:0];	//Matrix B
	reg [MATRIX_A_HEIGHT*MATRIX_B_WIDTH*WIDTH - 1:0] test_R [`N_TESTS - 1:0];	//A@B

	reg [SYS_HEIGHT*ARR_HEIGHT*SYS_WIDTH*ARR_HEIGHT*WIDTH - 1 : 0] expected_result;
	reg [32 - 1 : 0] data_in;

	//---Simulation Result---
	wire [SYS_HEIGHT*ARR_HEIGHT*SYS_WIDTH*ARR_WIDTH*WIDTH - 1 : 0] simul_result;

	//---Simulation Status---
	integer test_count = 0; 	//Number of Tests Executed
	integer pass = 0; 		//Number of Tests Passes
	integer fail = 0;		//Number of Tests Failed

	//---Signals---
	reg clk = 0;
	reg reset;
	reg data_in_flag = 0;
	
	//---Systolic Array Outputs---s
	wire calc_done_flag;

	//---Clock Signal---
	always #5 clk = ~clk;

	NDP_core #(
		.WIDTH(WIDTH), 
		.IS_FLOAT(IS_FLOAT), .EXP_BITS(EXP_BITS), .FRAC_BITS(FRAC_BITS),
		.ARR_WIDTH(ARR_WIDTH), .ARR_HEIGHT(ARR_HEIGHT),
		.SYS_WIDTH(SYS_WIDTH), .SYS_HEIGHT(SYS_HEIGHT)
	) NDP_core0  (
		.clk(clk),
		.reset(reset),
		.data_in_flag(data_in_flag),
		.data_in(data_in),
		.calc_done_flag(calc_done_flag),
		.out_c(simul_result)
	);

	//---Simulation---
	integer results_file; 	//file

	//---1. Read Vectors---
	initial
	begin
		$readmemb("SystolicTestVector_2stage/TestVectorA", test_A);
		$readmemb("SystolicTestVector_2stage/TestVectorB", test_B);
		$readmemb("SystolicTestVector_2stage/TestVectorR", test_R);
		results_file = $fopen("SystolicTestVector_2stage/Results.txt");
	end

	//---2. Calculate & Assess---
	integer i = 0;
	integer j = 0;

	integer act = 0;
	integer k = 0; //Test Set Number

	reg [2:0] step = 3'b000;

	always @(negedge clk) begin
		case(step)
			3'd0: begin
				reset = 0;
				step = 2'd1;
			end
			3'd1: begin
				reset = 1;
				step = 3'd2;
			end
			3'd2: begin
				reset = 0;
				act = 1;
				i = 0;
				j = 0;
				data_in_flag = 1;
				step = 3'd3;
			end
			3'd3: begin
				if(j == MATRIX_A_WIDTH - 1  && i == MATRIX_A_HEIGHT / 2 - 1) begin
					step = 3'd4;
					act = 0;
					i = 0;
					j = 0;
				end else if(i == MATRIX_A_HEIGHT / 2 - 1) begin
					i = 0;
					j = j + 1;
				end else begin
					i = i + 1;
				end
			end
			3'd4: begin
				if(j == MATRIX_A_WIDTH - 1  && i == MATRIX_B_WIDTH / 2 - 1) begin
					step = 3'd5;
					data_in_flag = 0;
				end else if(i == MATRIX_B_WIDTH / 2 - 1) begin
					i = 0;
					j = j + 1;
				end else begin
					i = i + 1;
				end
			end
			3'd5: begin
				if(calc_done_flag) begin 	//Wait for calculation to finish
					
					test_count = test_count + 1;
					expected_result = test_R[k];

					if(expected_result == simul_result) begin
						//---Pass---
						pass = pass + 1;
						$fdisplay (results_file,"%d: Passed, expected: %h, simul: %h", test_count, expected_result, simul_result);	
						$display("%d: Passed", test_count);	

					end else begin
						//---Fail---
						fail = fail + 1;
						$fdisplay (results_file,"%d: Failed, expected: %h, simul: %h", test_count, expected_result, simul_result);
						$display("%d: Failed", test_count);	
					end

					step = 3'd0;
					k = k + 1;

					if(k == `N_TESTS) begin
						//---Test Finished---
						if(pass == test_count) begin
							//---Test Success---
							$display ("Passed: %d/%d", pass, test_count);
							$fdisplay (results_file,"Passed: %d/%d", pass, test_count);
							$fclose(results_file);

						end else begin
							//---Test Fail---
							$display ("Failed: %d/%d", pass, test_count);
							$fdisplay (results_file,"Failed: %d/%d", pass, test_count);
							$fclose(results_file);
						end
						$finish;
					end
				end
			end
		endcase
	end

	always @(*) begin
		if(act) begin
			data_in = test_A[k][ARR_HEIGHT*SYS_HEIGHT*WIDTH*j+32*i +: 32];
		end else begin
			data_in = test_B[k][ARR_WIDTH*SYS_WIDTH*WIDTH*j+32*i +: 32];
		end
	end

// always @(posedge clk)
// 	$display("%d, %d, %h", i, j, data_in);

endmodule
