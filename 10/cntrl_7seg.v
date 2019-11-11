`timescale 1ns / 1ps

module cntrl_7seg(
   input clk,
   input rst,
   input [3:0] din0,
   input [3:0] din1,
   output [3:0] AN,
   output [7:0] SEG
);

// Enable signal with ~kHz frequency (rate generator)
wire en;
reg [16:0] Q;
/* TODO */
always @(posedge clk) // szamoljuk a felfuto eleket es eloallitjuk a kHz koruli orajelet a kijelzohoz
	if(rst | en) // ha reset vagy megvan az orajelszam nullazzuk a szamlalot
		Q <= 0;
	else
		Q <= Q + 1;
assign en = (Q == 15999); // orajel leosztasa  - 15999999 = 1Hz -> 15999 = 1kHz

// 4 bit shift register - inkabb cirkularis regiszter...
reg [3:0] shr;
always @(posedge clk)
	if(rst)
		shr <= 4'b1110;	// alacsony aktiv a kijelzo engedelyezes
	else if(en)
		shr <= {shr[2:0],shr[3]}; // forgatas balra, az aktualis msb-t minden engedejezett orajelre lsb-re lehozzuk
assign AN = shr;

// 2 bit counter
reg [1:0] cntr;
/* TODO */
always @(posedge clk)
	if(rst)
		cntr <= 0;
	else if(en)
		if(cntr == 3)
			cntr <= 0;
		else
			cntr <= cntr + 1;

// 4 bit 4:1 multiplexer
reg [3:0] dmux;
/* TODO */
always @(posedge clk)
	case (cntr)
		0: dmux <= din0;
		1: dmux <= din1;
		default: dmux <= 'bx;
	endcase
	
//segment decoder
reg [7:0] SEG_DEC;
always @(dmux)
	case (dmux)
		4'h0:    SEG_DEC <= 8'b00000011;
		4'h1:    SEG_DEC <= 8'b10011111;
		4'h2:    SEG_DEC <= 8'b00100101;
		4'h3:    SEG_DEC <= 8'b00001101;
		4'h4:    SEG_DEC <= 8'b10011001;
		4'h5:    SEG_DEC <= 8'b01001001;
		4'h6:    SEG_DEC <= 8'b01000001;
		4'h7:    SEG_DEC <= 8'b00011111;
		4'h8:    SEG_DEC <= 8'b00000001;
		4'h9:    SEG_DEC <= 8'b00001001;
		default: SEG_DEC <= 8'b11111111;
	endcase

assign SEG = SEG_DEC;

endmodule

/* init

wire [7:0] cntrl_7segSEG;
wire [3:0] cntrl_7segAN;
cntrl_7seg seg7count(
	.clk(clk),
	.rst(rst),
	.din0(cntr_d0),
	.din1({0, cntrl_d1}),
	.AN(cntrl_7segAN),
	.SEG(cntrl_7segSEG)
);
assign AN = cntrl_7segAN;
assign SEG = cntrl_7segSEG;

*/