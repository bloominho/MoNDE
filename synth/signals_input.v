
module signals_input (
	input			HCLK,
	input			HRESETn,
	input			HSEL,
	input [31:0]	HADDR,
	input			HWRITE,
	input [1:0]		HTRANS,
	input [2:0]		HSIZE,
	input [31:0]	HWDATA,
	output			HREADY,
	input			HREADYin,
	output [1:0]	HRESP,
	output reg [31:0] HRDATA,

	output [31:0] 	reset,
	output [31:0] 	start,
	output [31:0] 	finished
);

	reg [31:0]	curr_haddr;
	reg [31:0]	next_haddr;
	reg			curr_hwrite;
	reg			next_hwrite;
	reg [2:0]	curr_hsize;
	reg [2:0]	next_hsize;
	reg [31:0]	curr_reset;
	reg [31:0]	next_reset;
	reg [31:0]	curr_start;
	reg [31:0]	next_start;
	reg [31:0]	curr_finished;
	reg [31:0]	next_finished;
	reg [31:0]	curr_ext;
	reg [31:0]	next_ext;
	reg			curr_hsel;
	reg			next_hsel;
	reg [31:0]	sig_hwdata;
	reg [31:0]	sig_hrdata;

	assign HREADY = 1'b1;
	assign HRESP = 2'b00;
	assign reset = curr_reset;
	assign start = curr_start;
	assign finished = curr_finished;

  always @ (HSEL or HREADYin or HTRANS or HADDR or HWRITE or HSIZE or curr_haddr or
            curr_hwrite or curr_hsize)
  begin
    if (HSEL && HREADYin && HTRANS[1])
    begin
      next_haddr <= HADDR;
      next_hwrite <= HWRITE;
      next_hsize <= HSIZE;
      next_hsel <= 1'b1;
    end
    else
    begin
      next_haddr <= curr_haddr;
      next_hwrite <= curr_hwrite;
      next_hsize <= curr_hsize;
      next_hsel <= 1'b0;
    end
  end

  always @ (posedge HCLK or negedge HRESETn)
  begin
    if (!HRESETn)
    begin
      curr_haddr <= 32'd0;
      curr_hwrite <= 1'b0;
      curr_hsize <= 3'b010;
      curr_hsel <= 1'b0;
    end
    else
    begin
      curr_haddr <= next_haddr;
      curr_hwrite <= next_hwrite;
      curr_hsize <= next_hsize;
      curr_hsel <= next_hsel;
    end
  end

  always @ (curr_reset or curr_start or curr_finished or curr_hsel or curr_hwrite or curr_haddr or sig_hwdata)
  begin
    next_reset <= curr_reset;
    next_start <= curr_start;
    next_finished <= curr_finished;
    next_ext <= curr_ext;
    sig_hrdata <= 32'd0;
    if (curr_hsel)
    begin
      if (curr_hwrite)
      begin
        case (curr_haddr[5:2])
          4'b0000: next_reset <= sig_hwdata;
          4'b0001: next_start <= sig_hwdata;
          4'b0010: next_finished <= sig_hwdata;
          default: next_ext <= sig_hwdata;
        endcase
      end
      else
      begin
        case (curr_haddr[5:2])
          4'b0000: sig_hrdata <= curr_reset;
          4'b0001: sig_hrdata <= curr_start;
          4'b0010: sig_hrdata <= curr_finished;
          default: sig_hrdata <= 32'd0;
        endcase
      end
    end
  end
 
  always @ (posedge HCLK or negedge HRESETn)
  begin
    if (!HRESETn)
    begin
      curr_reset <= 32'd0;
      curr_start <= 32'd0;
      curr_finished <= 32'd0;
      curr_ext <= 32'd0;
    end
    else
    begin
      curr_reset <= next_reset;
      curr_start <= next_start;
      curr_finished <= next_finished;
      curr_ext <= next_reset;
    end
  end

  always @ (curr_hsize or HWDATA or curr_haddr or sig_hrdata)
  begin
    if (curr_hsize == 3'b001)
    begin
      sig_hwdata <= {2{HWDATA[15:0]}};
      if (curr_haddr[1])
        HRDATA <= {2{HWDATA[31:16]}};
      else
        HRDATA <= {2{HWDATA[15:0]}};
    end
    else if (curr_hsize == 3'b000)
    begin
      sig_hwdata <= {4{HWDATA[7:0]}};
      if (curr_haddr[1:0] == 2'b11)
        HRDATA <= {4{sig_hrdata[31:24]}};
      else if (curr_haddr[1:0] == 2'b10)
        HRDATA <= {4{sig_hrdata[23:16]}};
      else if (curr_haddr[1:0] == 2'b01)
        HRDATA <= {4{sig_hrdata[15:8]}};
      else
        HRDATA <= {4{sig_hrdata[7:0]}};
    end
    else
    begin
      HRDATA <= sig_hrdata;
      sig_hwdata <= HWDATA;
    end
  end

endmodule
