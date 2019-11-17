`timescale 1ns / 1ps
 module dproc(
    input clk,
    input rst,
    input [12:0] temp,	 //Temperature input
    input [7:0] sw,		 //sw[6:0] is displayed or subtracted from temp depending on sw[7]
    output reg [3:0] d3, //sign
    output [3:0] 		d2, //MSByte
    output [3:0] 		d1, //LSB
    output reg [3:0] d0	 //Fraction
    );

//input sync
reg [7:0] sw_ff;
always @(posedge clk)
	if (rst) sw_ff <= 0;
	else sw_ff <= sw; 



// BCD Converter ----------------------------------------------------------------------------
reg  [7:0] data_in; //BCD converter input 
reg  [7:0] data_out; 
reg  [7:0] data_old; 
reg  [7:0] data_conv; 
reg  [3:0] data_high; 		

always @(posedge clk)
	if (~(data_in==data_old) | rst) begin
		data_old <= data_in;
		data_conv <= data_in;
		data_high <= 0;
		if(rst) data_out <=0;
	end
	else if (data_conv > 9) begin
		data_conv <= data_conv - 10;
		data_high <= data_high + 1;
	end
	else data_out <= {data_high, data_conv[3:0]};


//The BCD converter output is assigned to the middle digits of the 7seg display
assign d1 = data_out[3:0];
assign d2 = data_out[7:4];

//Converting 2-complement temperature value -------------------------------------------------
always @(posedge clk)
	data_in <= ~data_in;

//Offset - read from sw[6:0]
wire [12:0] temp_off;
assign temp_off = temp - {2'b0,sw_ff[6:0],4'b0};

//Absolute value *TODO*
wire [11:0] temp_abs;
assign temp_abs = temp_off[11:0];


//Decimal fraction - this description will be optimized (generates warning),
// in exchange it is well readable.
//The resolution of temp_abs[3:0] is 1/16 degree
wire [3:0] frac;
wire [6:0] frac_mult;
assign frac_mult = {temp_abs[3:0],2'b00} + temp_abs[3:0]; //5*temp_abs
assign frac = frac_mult[6:3];  //divide with 8   [ (frac_mult/8) or (frac_mult>>3) are also ok]


//Selecting BCD decoder input and 7seg output based on sw[7]  -----------------------------------
always @(posedge clk)
	if(rst) begin
		data_in <= 0;
		d3 <= 0;
		d0 <= 0;
	end
	else begin
		data_in <= sw_ff[7] ? temp_abs[11:4] : {1'b0,sw_ff[6:0]};
		d3 <=      sw_ff[7] ? {3'b110,temp_off[12]} : 15;
		d0 <=      sw_ff[7] ? frac : 15;
	end


endmodule
