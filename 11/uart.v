module uart(
	 input clk,
    input rst,
    input [6:0] bcd0,
    input [6:0] bcd1,
    output reg tx_out,
	 output [6:0] cntr_out,
	 output [29:0] shr_out
    );
	 
always @ (posedge clk)
	if(rst)
		tx_out <= 1;
		
reg [8:0] cntr; // 9bit reg
wire tx_change_en;
always @ (posedge clk)
	if(rst | tx_change_en) 
		cntr <= 0;
	else
		cntr <= cntr + 1;
		
assign tx_change_en = (cntr == 278); // 16Mhz / 57600bps = 277.7 -> kb 278

reg [6:0] shift_cntr;
wire shift_en;
always @ (posedge clk)
	if(rst | shift_en)
		shift_cntr <= 0;
	else if(tx_change_en)
		shift_cntr <= shift_cntr + 1;

assign shift_en = (shift_cntr == 30);

reg [6:0] cr = 'b0001101; // 0d = carriage return 
reg [20:0] shr;
wire [6:0] bcd1_in;
wire [6:0] bcd0_in;
wire parity1, parity0, parityCr;
assign bcd1_in = (bcd1[6:0] + 48);
assign bcd0_in = (bcd0[6:0] + 48);
assign parity1 = ~(^bcd1_in);
assign parity0 = ~(^bcd0_in);
assign parityCr = ~(^cr);
assign par = parity0;
assign shr_out = shr;
always @ (posedge clk)
	if(tx_change_en)
		case(shift_cntr)
			0: begin 
				shr <= {cr[6:0], bcd0_in[6:0], bcd1_in[6:0]};
				tx_out <= 0; // start bit
				end
			8: tx_out <= parity1;
			9: tx_out <= 1;
			10: tx_out <= 0;
			18: tx_out <= parity0;
			19: tx_out <= 1;
			20: tx_out <= 0;
			28: tx_out <= parityCr;
			29: tx_out <= 1;
			default: begin
				shr <= {1, shr[20:1]};
				tx_out <= shr[0];
				end
		endcase

assign cntr_out = shift_cntr; // only for test
endmodule
