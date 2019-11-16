`timescale 1ns / 1ps
module spi(
    input clk,
    input rst,
    output nCS,
    output sck,
    input miso,
    output [12:0] Dout
    );


//23 cntr, clk is 16 MHz
reg [22:0] cntr;
//*TODO*
always @ (posedge clk)
	if(rst)
		cntr <= 0;
	else
		cntr <= cntr + 1;

//sck should be 4 MHz, Generating sck_rise
wire sck_rise;
//*TODO*
assign sck = cntr[1];
assign sck_rise = (cntr[1:0] == 'b01); // cntr utolso 2 bitjet vizsgaljuk - sck felfutasa elott


//Generating Chip Select
reg cs_ff;
//*TODO*
wire d_rst;
wire d_set;
assign d_rst = (cntr[22:0] == 'b11 ); // 3
assign d_set = (cntr[22:0] == 'b1000011); // 67
always @ (posedge clk)
	if(d_set | rst)
		cs_ff <= 1;
	else if(d_rst)
		cs_ff <= 0;
			
assign nCS = cs_ff;

//Shift register for data receiving 
reg [15:0] shr;
//*TODO*
wire shr_in_en;
assign shr_in_en = (sck_rise & (~nCS));
always @ (posedge clk)
	if(rst)
		shr <= 0;
	else if(shr_in_en)
		shr <= {shr[14:0], miso};

//Output register for storing consistent data
reg [12:0] Dout_reg;
//*TODO*
always @ (posedge clk)
	if(rst)
		Dout_reg <= 0;
	else if(nCS)
		Dout_reg <= shr[15:3];
assign Dout = Dout_reg;

endmodule
