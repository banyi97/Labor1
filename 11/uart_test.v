`timescale 1ns / 1ps

module uart_test;

	// Inputs
	reg clk;
	reg rst;
	reg [6:0] bcd0;
	reg [6:0] bcd1;

	// Outputs
	wire tx_out;
	wire [6:0] cntr_out;
	wire [29:0] shr_out;

	// Instantiate the Unit Under Test (UUT)
	uart uut (
		.clk(clk), 
		.rst(rst), 
		.bcd0(bcd0), 
		.bcd1(bcd1), 
		.tx_out(tx_out), 
		.cntr_out(cntr_out), 
		.shr_out(shr_out)
	);

	reg dir;
	wire en;
	reg [16:0] cntr;
	always @ (posedge clk)
		if(rst | en)
			cntr <= 0;
		else
			cntr <= cntr + 1;
	assign en = (cntr == 8500);
	
	always @ (posedge clk)
		if(en)
			if(dir) begin
				bcd0 = 2;
				bcd1 = 1;
				dir <= ~dir;				
			end
			else begin
				bcd0 = 9;
				bcd1 = 0;	
				dir <= ~dir;
			end
	
	initial begin
		// Initialize Inputs
		clk = 1;
		dir = 0;
		rst = 1;
		bcd0 = 2;
		bcd1 = 1;
		#102;
		rst = 0;
	end
	always #10 clk = ~clk;
      
endmodule

