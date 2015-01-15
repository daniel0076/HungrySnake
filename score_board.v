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
	//input isDecresing,
    input decr,
	output reg gameover,
	//
    input [11:0] x_p, // 12-bit, in screen coordinate
    input [11:0] y_p, // 12-bit, in screen coordinate
    output reg isFilled
    );
//////// score ////////
reg [4:0] score[3:0]; // The score
wire zero_score, one_score;
assign zero_score=(~|score[3] && ~|score[2] && ~|score[1] && ~|score[0]);
assign one_score=(~|score[3] && ~|score[2] && ~|score[1] && score[0]==4'd1);

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
reg [15:0] addr_mem,addr_mem_offset;
wire dout_mem;
`define OFFSET_0 16'd0
`define OFFSET_1 16'd4800
`define OFFSET_2 16'd9600
`define OFFSET_3 16'd14400
`define OFFSET_4 16'd19200
`define OFFSET_5 16'd24000
`define OFFSET_6 16'd28800
`define OFFSET_7 16'd33600
`define OFFSET_8 16'd38400
`define OFFSET_9 16'd43200

////////////////  ////////////////

//////// score ////////
always@(posedge clk) begin
	if(reset)
		gameover<=1'b0;
	else if (decr && one_score)
		gameover<=1'b1;
	else
		gameover<=gameover;
end
always@(posedge clk) begin
	if(reset) begin
		score[3]<=4'd0;
		score[2]<=4'd0;
		score[1]<=4'd0;
		score[0]<=4'd0;
	end
	else if(gameover) begin
		score[3]<=4'd0;
		score[2]<=4'd0;
		score[1]<=4'd0;
		score[0]<=4'd0;
	end
	else if(decr) begin
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
//////// memory ////////
blk_mem_digit_pattern_60x80x10x1 mem_digit_pattern(
	.clka(clk),
	.addra(addr_mem),
	.douta (dout_mem)
);
always@(*) begin
	case(section)
		3'd0: case(score[0])
			4'd0: addr_mem_offset=`OFFSET_0;
			4'd1: addr_mem_offset=`OFFSET_1;
			4'd2: addr_mem_offset=`OFFSET_2;
			4'd3: addr_mem_offset=`OFFSET_3;
			4'd4: addr_mem_offset=`OFFSET_4;
			4'd5: addr_mem_offset=`OFFSET_5;
			4'd6: addr_mem_offset=`OFFSET_6;
			4'd7: addr_mem_offset=`OFFSET_7;
			4'd8: addr_mem_offset=`OFFSET_8;
			4'd9: addr_mem_offset=`OFFSET_9;
			default: addr_mem_offset=`OFFSET_8; // a strange case, should not happen
		endcase
		3'd1: case(score[1])
			4'd0: addr_mem_offset=`OFFSET_0;
			4'd1: addr_mem_offset=`OFFSET_1;
			4'd2: addr_mem_offset=`OFFSET_2;
			4'd3: addr_mem_offset=`OFFSET_3;
			4'd4: addr_mem_offset=`OFFSET_4;
			4'd5: addr_mem_offset=`OFFSET_5;
			4'd6: addr_mem_offset=`OFFSET_6;
			4'd7: addr_mem_offset=`OFFSET_7;
			4'd8: addr_mem_offset=`OFFSET_8;
			4'd9: addr_mem_offset=`OFFSET_9;
			default: addr_mem_offset=`OFFSET_8;
		endcase
		3'd2: case(score[2])
			4'd0: addr_mem_offset=`OFFSET_0;
			4'd1: addr_mem_offset=`OFFSET_1;
			4'd2: addr_mem_offset=`OFFSET_2;
			4'd3: addr_mem_offset=`OFFSET_3;
			4'd4: addr_mem_offset=`OFFSET_4;
			4'd5: addr_mem_offset=`OFFSET_5;
			4'd6: addr_mem_offset=`OFFSET_6;
			4'd7: addr_mem_offset=`OFFSET_7;
			4'd8: addr_mem_offset=`OFFSET_8;
			4'd9: addr_mem_offset=`OFFSET_9;
			default: addr_mem_offset=`OFFSET_8;
		endcase
		3'd3: case(score[3])
			4'd0: addr_mem_offset=`OFFSET_0;
			4'd1: addr_mem_offset=`OFFSET_1;
			4'd2: addr_mem_offset=`OFFSET_2;
			4'd3: addr_mem_offset=`OFFSET_3;
			4'd4: addr_mem_offset=`OFFSET_4;
			4'd5: addr_mem_offset=`OFFSET_5;
			4'd6: addr_mem_offset=`OFFSET_6;
			4'd7: addr_mem_offset=`OFFSET_7;
			4'd8: addr_mem_offset=`OFFSET_8;
			4'd9: addr_mem_offset=`OFFSET_9;
			default: addr_mem_offset=`OFFSET_8;
		endcase
		default: addr_mem_offset=16'b0;
	endcase
end
// give `addr_mem' first in order to give out `isFilled'
always@(*) begin
	case(section)
		3'd0: addr_mem=addr_mem_offset+y*16'd60+x-16'd740;
		3'd1: addr_mem=addr_mem_offset+y*16'd60+x-16'd680;
		3'd2: addr_mem=addr_mem_offset+y*16'd60+x-16'd620;
		3'd3: addr_mem=addr_mem_offset+y*16'd60+x-16'd560;
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
