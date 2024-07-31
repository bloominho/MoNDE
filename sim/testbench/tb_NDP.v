`timescale 1ns/10ps

`define N_TESTS 100

module tb_top;
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
	parameter SYS_WIDTH = 16;

	//---Testbench Data---
	parameter MATRIX_A_HEIGHT = SYS_HEIGHT*ARR_HEIGHT;
	parameter MATRIX_A_WIDTH = 21;
	parameter MATRIX_B_HEIGHT = MATRIX_A_WIDTH;
	parameter MATRIX_B_WIDTH = SYS_WIDTH*ARR_WIDTH;

	reg [MATRIX_A_HEIGHT*MATRIX_A_WIDTH*WIDTH - 1:0] test_A [`N_TESTS - 1:0];	//Matrix A
	reg [MATRIX_B_HEIGHT*MATRIX_B_WIDTH*WIDTH - 1:0] test_B [`N_TESTS - 1:0];	//Matrix B
	reg [MATRIX_A_HEIGHT*MATRIX_B_WIDTH*WIDTH - 1:0] test_R [`N_TESTS - 1:0];	//A@B

	reg [SYS_HEIGHT*ARR_HEIGHT*SYS_WIDTH*ARR_HEIGHT*WIDTH - 1 : 0] expected_result;

	//---Simulation Result---
	wire [SYS_HEIGHT*ARR_HEIGHT*SYS_WIDTH*ARR_WIDTH*WIDTH - 1 : 0] simul_result;

	//---Simulation Status---
	integer test_count = 0; 	//Number of Tests Executed
	integer pass = 0; 		//Number of Tests Passes
	integer fail = 0;		//Number of Tests Failed

	reg sample_pass;

	//---Signals---
	reg clk = 0;
	reg reset;

	//--- 
	reg [32:0] m_axis_tdata;
	wire 		m_axis_tkeep;
	reg 		m_axis_tlast;
	reg 		m_axis_tvalid;
	wire 		m_axis_tready;

	
	wire [31:0] s_axis_tdata;
	wire 		s_axis_tkeep;
	wire 		s_axis_tlast;
	wire 		s_axis_tvalid;
	wire 		s_axis_tready;

	//---Clock Signal---
	always #5 clk = ~clk;

	NDP_core NDP_core0 (
		.axi_aclk		(clk),
		.axi_aresetn	(~reset),
		.ps_clk			(clk),

		.s_axis_tdata	(m_axis_tdata),
		.s_axis_tkeep	(m_axis_tkeep),
		.s_axis_tlast	(m_axis_tlast),
		.s_axis_tvalid	(m_axis_tvalid),
		.s_axis_tready	(m_axis_tready),

		.m_axis_tdata	(s_axis_tdata),
		.m_axis_tkeep	(s_axis_tkeep),
		.m_axis_tlast	(s_axis_tlast),
		.m_axis_tvalid	(s_axis_tvalid),
		.m_axis_tready	(1'b1)
	);

	//---Simulation---
	integer results_file; 	//file

	//---1. Read Vectors---
	initial
	begin
		$readmemb("../SystolicTestVector_NDP/TestVectorA", test_A);
		$readmemb("../SystolicTestVector_NDP/TestVectorB", test_B);
		$readmemb("../SystolicTestVector_NDP/TestVectorR", test_R);
		results_file = $fopen("../SystolicTestVector_NDP/Results.txt");
	end

	//---2. Calculate & Assess---
	integer i = 0;
	integer j = 0;
	integer l = 0;

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
				
				m_axis_tlast = 0;
				m_axis_tvalid = 0;
			end
			3'd2: begin
				reset = 0;

				act = 1;
				i = 0;
				j = 0;
				
				m_axis_tlast = 0;
				m_axis_tvalid = 1;
				if(m_axis_tready) begin
					step = 3'd3;
				end
			end
			3'd3: begin
				if(m_axis_tready) begin
					if(i == MATRIX_A_HEIGHT / 2 - 1) begin
						step = 3'd4;
						act = 0;
						i = 0;
					end else begin
						i = i + 1;
					end
				end
			end
			3'd4: begin
				if(m_axis_tready) begin
					if(j == MATRIX_A_WIDTH - 1  && i == MATRIX_B_WIDTH / 2 - 1) begin
						m_axis_tvalid = 0;
					end else if(i == MATRIX_B_WIDTH / 2 - 1) begin
						step = 3'd3;
						act = 1;
						i = 0;
						j = j + 1;
					end else begin
						i = i + 1;
					end

					if(j == MATRIX_A_WIDTH - 1  && i == MATRIX_B_WIDTH / 2 - 1) begin
						step = 3'd5;
						m_axis_tlast = 1;
						sample_pass = 1;
						l = 0;
					end
				end
			end
			3'd5: begin
				m_axis_tvalid = 0;
				if(s_axis_tvalid) begin 	//Wait for calculation to finish
					expected_result = test_R[k];

					if(s_axis_tdata == expected_result[l*32 +: 32]) begin
						sample_pass = sample_pass;
					end else begin
						$fdisplay (results_file,"expected: %h, simul: %h", expected_result[l*32 +: 32], s_axis_tdata);	
						sample_pass = 0;
					end
					l = l + 1;

					if(s_axis_tlast) begin
						test_count = test_count + 1;
						if(sample_pass) begin
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

						step = 3'd2;
						k = k + 1;
					end

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
			m_axis_tdata = test_A[k][ARR_HEIGHT*SYS_HEIGHT*WIDTH*j+32*i +: 32];
		end else begin
			m_axis_tdata = test_B[k][ARR_WIDTH*SYS_WIDTH*WIDTH*j+32*i +: 32];
		end
	end

endmodule
