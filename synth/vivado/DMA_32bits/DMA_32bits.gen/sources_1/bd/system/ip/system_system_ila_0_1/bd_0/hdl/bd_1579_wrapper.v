//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_1579_wrapper.bd
//Design : bd_1579_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_1579_wrapper
   (clk,
    probe0,
    probe1,
    probe2,
    probe3,
    probe4,
    probe5,
    probe6,
    probe7,
    probe8,
    probe9);
  input clk;
  input [63:0]probe0;
  input [1023:0]probe1;
  input [15:0]probe2;
  input [1:0]probe3;
  input [0:0]probe4;
  input [5:0]probe5;
  input [3:0]probe6;
  input [63:0]probe7;
  input [1023:0]probe8;
  input [15:0]probe9;

  wire clk;
  wire [63:0]probe0;
  wire [1023:0]probe1;
  wire [15:0]probe2;
  wire [1:0]probe3;
  wire [0:0]probe4;
  wire [5:0]probe5;
  wire [3:0]probe6;
  wire [63:0]probe7;
  wire [1023:0]probe8;
  wire [15:0]probe9;

  bd_1579 bd_1579_i
       (.clk(clk),
        .probe0(probe0),
        .probe1(probe1),
        .probe2(probe2),
        .probe3(probe3),
        .probe4(probe4),
        .probe5(probe5),
        .probe6(probe6),
        .probe7(probe7),
        .probe8(probe8),
        .probe9(probe9));
endmodule
