module NDP_controller #() (
	
);

NDP_core ndp_core (
	.clk(), .reset(),
	.data_in_flag(), 
	.data_read_flag(),		// Whether data is accepted by NDP core

	.calc_done_flag()
	.out_c()
);
endmodule