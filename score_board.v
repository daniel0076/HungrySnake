`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:05:19 12/23/2014 
// Design Name: 
// Module Name:    score_board 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:
//	. Input data: `x', `y'
//	. Output data: `isFilled'
//	. The module gives 1'b1 to `isFilled' 
//		if the pixel at (`x', `y') is filled with a different color from the background color.
//	. Scores are stored in this module with 4 binary-decimal numbers.
//  . To do addition to or decrease the score, just give one cycle of `clk' of add or decrease, respectively.
//	. `gameover' will be set if the score is zero and `decrease' is set.
// Dependencies: 
//
// Revision: ???
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module score_board(
    input clk, // clock of the fpga (100MHz)
	input reset,
	//input clk_mem, // clock for reading memory
    //input clk_change,
	//input [3:0] addend; 
    input add, // score will add 1 in a clock cycle if (add==1)
    input decr,
	output gameover,
	//
    input [11:0] x_p, // 12-bit, in screen coordinate
    input [11:0] y_p, // 12-bit, in screen coordinate
    output reg isFilled
    );
//////// score ////////
reg [4:0] score[4:0]; // The score
wire zero;
assign zero=(~|score[3] && ~|score[2] && ~|score[1] && ~|score[0]);

//////// x, y ////////
reg [11:0] x,y;
always@(*) begin
	case(x_p)
		12'd799: begin
			case(y_p)
				12'd599: begin
					x=12'd0;
					y=12'd0;
				end
				default: begin
					x=12'd0;
					y=y_p+12'd1;
				end
			endcase
		end
		default: begin
			x=x_p+12'd1;
			y=y_p;
		end
	endcase
end

reg [2:0] section;
always@(*) begin
	if(x<12'd560) // left
		section=3'd4;
	else if(y<12'd80) begin 
		// `x' is in [560,800), and `y' is in [0,80).
		if(x>=12'd740) // `x' is in [740,800) for score[0]
			section=3'd0;
		else if (x>=12'd680) // `x' is in [680,740) for score[1]
			section=3'd1;
		else if (x>=12'd620) // `x' is in [620,680) for score[2]
			section=3'd2;
		else // `x' is in [560,620) for score[3]
			section=3'd3;
	end
	else
		section=3'd4;
end

//////// memory ////////
reg [15:0] addr_mem;
wire dout_mem;

////////////////  ////////////////

//////// score ////////
assign gameover=0; // not defined yet
/*
always@(posedge clk) begin
	if(reset)
		gameover<=1'b0;
	else if (decr && zero)
		gameover<=1'b1;
end
*/
always@(posedge clk) begin
	if(reset) begin
		score[3]<=4'd0;
		score[2]<=4'd0;
		score[1]<=4'd0;
		score[0]<=4'd0;
	end
	else begin
		if(decr) begin
			if(|score[0]) begin // no borrow
				score[0]<=score[0]-4'd1;
			end
			else if(|score[1]) begin
				score[0]<=4'd9;
				score[1]<=score[1]-4'd1;
			end
			else if(|score[2]) begin
				score[0]<=4'd9;
				score[1]<=4'd9;
				score[2]<=score[2]-4'd1;
			end
			else if(|score[3]) begin
				score[0]<=4'd9;
				score[1]<=4'd9;
				score[2]<=4'd9;
				score[3]<=score[3]-4'd1;
			end
			else begin
				score[0]<=4'd0;
				score[1]<=4'd0;
				score[2]<=4'd0;
				score[3]<=4'd0;
			end
		end
		else if(add) begin
			// do addition
			if(score[0]<4'd9) begin // no carry
				score[0]<=score[0]+4'd1;
			end
			else if(score[1]<4'd9) begin
				score[0]<=4'd0;
				score[1]<=score[1]+4'd1;
			end
			else if(score[2]<4'd9) begin
				score[0]<=4'd0;
				score[1]<=4'd0;
				score[2]<=score[2]+4'd1;
			end
			else begin
				score[0]<=4'd0;
				score[1]<=4'd0;
				score[2]<=4'd0;
				score[3]<=score[3]+4'd1;
			end
			// Since `score' is always less than d10000, it is not need to deal with the carry from score[3].
		end
	end
end
//////// memory ////////
blk_mem_digit_pattern_60x80x10x1 mem_digit_pattern(
	.clka(clk),
	.addra(addr_mem),
	.douta (dout_mem)
);
// give `addr_mem' first in order to give out `isFilled'
always@(*) begin
	case(section)
		3'd0: addr_mem=y*16'd60+x-16'd740;
		3'd1: addr_mem=y*16'd60+x-16'd680;
		3'd2: addr_mem=y*16'd60+x-16'd620;
		3'd3: addr_mem=y*16'd60+x-16'd560;
		default: addr_mem=16'b0;
	endcase
end
// output `isFilled'
always@(*) begin
	case(section)
		3'd0: begin
			isFilled=dout_mem;
		end
		3'd1: begin
			if(~|score[3] && ~|score[2] && ~|score[1])
				isFilled=1'b0;
			else
				isFilled=dout_mem;
		end
		3'd2: begin
			if(~|score[3] && ~|score[2])
				isFilled=1'b0;
			else
				isFilled=dout_mem;
		end
		3'd3: begin
			if(~|score[3])
				isFilled=1'b0;
			else
				isFilled=dout_mem;
		end
		default: begin
			isFilled=dout_mem;
		end
	endcase
end
endmodule
