`timescale 1ns / 1ps

module running_light(
	input clk,
	input en,
	input rst,
   output [7:0] leds
);

reg [7:0] Q;
reg dir; // 0 left, 1 rigth

wire q_is_min;
wire q_is_max;
always @(posedge clk)
	if(rst)
		begin
			Q <= 8'b00000001;
			dir <= 0;
		end
	else if(en)
			if(~dir) // balra shifteles
				if(q_is_max)
					begin
					dir <= ~dir; // forgasiranyvaltas
					Q <= {Q[0],Q[7:1]};
					end
				else
					Q <= {Q[6:0],Q[7]};
			else		// jobbra shifteles
				if(q_is_min)
					begin
					dir <= ~dir; // forgasiranyvaltas
					Q <= {Q[6:0],Q[7]};
					end
				else
					Q <= {Q[0],Q[7:1]};
		
assign leds = Q;
assign q_is_min = (Q == 8'b00000001);
assign q_is_max = (Q == 8'b10000000);
endmodule

/* init

wire [6:0] running_ligthLeds;
running_light runnLigth(
	.clk(clk),
	.rst(rst),
	.en(ce),
	.leds(running_ligthLeds)
);
assign q = running_ligthLeds[6:0];
assign blink = running_ligthLeds[7];

*/
