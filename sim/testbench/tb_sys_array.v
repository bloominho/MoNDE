`timescale 1ns/10ps

`define N_TESTS 100

module tb_sys_array;
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
	parameter SYS_WIDTH = 1;

	//---Testbench Data---
	parameter MATRIX_A_HEIGHT = SYS_HEIGHT*ARR_HEIGHT;
	parameter MATRIX_A_WIDTH = 5;
	parameter MATRIX_B_HEIGHT = MATRIX_A_WIDTH;
	parameter MATRIX_B_WIDTH = SYS_WIDTH*ARR_WIDTH;

	reg [MATRIX_A_HEIGHT*MATRIX_A_WIDTH*WIDTH - 1:0] test_A [`N_TESTS - 1:0];	//Matrix A
	reg [MATRIX_B_HEIGHT*MATRIX_B_WIDTH*WIDTH - 1:0] test_B [`N_TESTS - 1:0];	//Matrix B
	reg [MATRIX_A_HEIGHT*MATRIX_B_WIDTH*WIDTH - 1:0] test_R [`N_TESTS - 1:0];	//A@B

	reg [SYS_HEIGHT*ARR_HEIGHT*SYS_WIDTH*ARR_HEIGHT*WIDTH - 1 : 0] expected_result;
	reg [SYS_HEIGHT*ARR_HEIGHT*WIDTH - 1 : 0] in_a;		//column
	reg [SYS_WIDTH*ARR_WIDTH*WIDTH - 1 :0] in_b;		//row

	//---Simulation Result---
	wire [SYS_HEIGHT*ARR_HEIGHT*SYS_WIDTH*ARR_WIDTH*WIDTH - 1 : 0] simul_result;

	//---Simulation Status---
	integer test_count = 0; 	//Number of Tests Executed
	integer pass = 0; 		//Number of Tests Passes
	integer fail = 0;		//Number of Tests Failed

	//---Signals---
	reg clk = 0;
	reg reset;
	reg in_done_flag = 0;
	
	//---Systolic Array Outputs---
	wire [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] out_a;
	wire [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] out_b;
	wire calc_done_flag;

	//---Clock Signal---
	always #5 clk = ~clk;


	NDP_unit #(
			.WIDTH(WIDTH), 
			.IS_FLOAT(IS_FLOAT), .EXP_BITS(EXP_BITS), .FRAC_BITS(FRAC_BITS), 
			.ARR_WIDTH(ARR_WIDTH), .ARR_HEIGHT(ARR_HEIGHT), .SYS_WIDTH(SYS_WIDTH), .SYS_HEIGHT(SYS_HEIGHT)
		) NDPUnit (
			.clk(clk), .reset(reset),
			.in_a(in_a), .in_b(in_b),
			.out_c(simul_result),
			.in_done_flag(in_done_flag),
			.calc_done_flag(calc_done_flag),
			.SIMD_control(2'b00)
	);


	//---Simulation---
	integer results_file; 	//file

	//---1. Read Vectors---
	initial
	begin
		$readmemb("SystolicTestVector/TestVectorA", test_A);
		$readmemb("SystolicTestVector/TestVectorB", test_B);
		$readmemb("SystolicTestVector/TestVectorR", test_R);
		results_file = $fopen("SystolicTestVector/Results.txt");
	end

	//---2. Calculate & Assess---
	integer i = 0; //row&column number inside each matrix
	integer k = 0; //Test Set Number

	reg [1:0] step = 2'b00;

	always @(negedge clk) begin
		case(step)
			2'b00: begin //Reset
				reset = 1;
				step = 2'b01;
				i = 0;
			end
			2'b01: begin //Feed Data
				if(i == MATRIX_A_WIDTH) begin
					in_done_flag = 1;
					step = 2'b10;
				end else begin
					reset = 0;
					in_done_flag = 0;
					
					in_a = test_A[k][i*MATRIX_A_HEIGHT*WIDTH +: MATRIX_A_HEIGHT*WIDTH];
					in_b = test_B[k][i*MATRIX_B_WIDTH*WIDTH +: MATRIX_B_WIDTH*WIDTH];

					i = i + 1;	
				end
			end
			2'b10: begin // Wait for calculation to finish, evalute results
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

					step = 2'b00;
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

endmodule
