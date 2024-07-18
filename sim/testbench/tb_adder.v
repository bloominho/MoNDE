`timescale 1ns/10ps

`define N_TESTS 10000

module tb_adder;
	//---DATA WIDTH---
	parameter WIDTH = 32;

	parameter EXP_BITS = 8;
	parameter FRAC_BITS = 23;

	//---Testbench Data---
	reg [WIDTH - 1 : 0] test_A [`N_TESTS - 1 : 0];
	reg [WIDTH - 1 : 0] test_B [`N_TESTS - 1 : 0];
	reg [WIDTH - 1 : 0] test_R [`N_TESTS - 1 : 0];
	
	reg [WIDTH - 1 : 0] in_a;
	reg [WIDTH - 1 : 0] in_b;

	reg [WIDTH - 1 : 0] expected_result;

	//---Simulation Result---
	wire [WIDTH - 1 : 0] simul_result;

	//---Simulation Status---
	integer test_count = 0; 	//Number of Tests Executed
	integer pass = 0; 		//Number of Tests Passes
	integer fail = 0;		//Number of Tests Failed

	//---Signals---
	reg clk = 0;
	reg reset;

	//---Clock Signal---
	always #5 clk = ~clk;

	DW_fp_add #(FRAC_BITS, EXP_BITS, 1) ADD (
		.a(in_a), 
		.b(in_b),
		.rnd(3'b000),
		.z(simul_result),
		.status()
	);

	//---Simulation---
	integer results_file; 	//file

	//---1. Read Vectors---
	initial
	begin
		$readmemb("../AdderTestVector/TestVectorAddA", test_A);
		$readmemb("../AdderTestVector/TestVectorAddB", test_B);
		$readmemb("../AdderTestVector/TestVectorAddR", test_R);
		results_file = $fopen("../AdderTestVector/AddSimulResults.txt");
	end

	//---2. Calculate & Assess---
	integer k = -3;
	always @(posedge clk) begin
		if(k == -3) begin
			reset = 0;
		end else if(k == -2) begin
			//--- Reset ---
			reset = 1;
		end else if(k == -1) begin
			reset = 0;
		end else begin
			//--- Feed Test Data---
			in_a <= test_A[k];
			in_b <= test_B[k];
			expected_result <= test_R[k];
		end
		
		k = k + 1;
	end

	always @(negedge clk) begin
		if(k > 0) begin
			//---Evaluate Data------
			if(simul_result == expected_result) begin
				pass = pass + 1;
				$fdisplay (results_file,"%d: Passed, expected: %b, simul: %b", test_count, expected_result, simul_result);	
				$display("%d: Passed", test_count);
			end else begin
				fail = fail + 1;
				$fdisplay (results_file,"%d: Failed, A: %b_%d_%b, B: %b_%d_%b, expected: %b_%b_%b, simul: %b_%b_%b", test_count, in_a[31], in_a[30:23], in_a[22:0], in_b[31], in_b[30:23], in_b[22:0], expected_result[31], expected_result[30:23], expected_result[22:0], simul_result[31], simul_result[30:23], simul_result[22:0]);
				$display("%d: Failed", test_count);	
			end
			test_count = test_count + 1;

			//---Test Finished---
			if(test_count == `N_TESTS) begin
				if(pass == k) begin
					//---Test Success---
					$display ("Passed: %d/%d", pass, test_count);
					$fdisplay (results_file,"Passed: %d/%d", pass, test_count);
					$fclose(results_file);
				end else begin
					//---Test Fail---
					$display ("Passed: %d/%d", pass, test_count);
					$fdisplay (results_file,"Failed: %d/%d", pass, test_count);
					$fclose(results_file);
				end
				$finish;
			end
		end
	end

endmodule
