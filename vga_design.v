`timescale 1ns / 1ps

`define Width 'd800
`define Height 'd600
`define Space 36
`define R 20
`define Area 400

module vga_design( CLK,RESET,SW,BTN_L,BTN_R,BTN_U,BTN_D,vga_h_out_r,vga_v_out_r,vga_data_w );
//vga design
input CLK,RESET;
input BTN_D,BTN_R,BTN_L,BTN_U;
input [1:0] SW;
output reg vga_h_out_r,vga_v_out_r;
output [11:0] vga_data_w;
//vga_out
wire vga_clk;
wire signed [11:0] x,y;
reg [11:0] x_m,y_m; //x y on the monitor
//memory
reg wen;
wire [18:0] addr_w,vga_addr;
wire [5:0] out_a;
wire [5:0] rgb_data;

//color
reg [1:0] color_r,color_g,color_b;
reg [25:0] counter;
wire snake_clk; //1.5 Hz

reg [3:0] g_c_state,g_n_state;
reg [3:0] f_c_state,f_n_state;
reg refill_done;
reg gg;
reg [7:0] r;
//snake record
reg signed [11:0] x1,x2,x3,x4,x5,x6,x7,x8,x9,x10;
reg signed [11:0] y1,y2,y3,y4,y5,y6,y7,y8,y9,y10;
reg [5:0] length;
///////////////////// write from here ////////////////////////////////////////
//this is for generic
`define IDLE       'd0
`define PLAY       'd1
`define GG         'd2
`define PAUSE    'd3
//this is for snake
`define RIGHT       'd4
`define LEFT        'd5
`define UP          'd6
`define DOWN        'd7
// This is for food
`define F_WAIT  'd8
`define F_GEN     'd9

///////////////////// counter /////////////////////////
always @(posedge CLK) begin
    if (RESET)
        // reset
    counter <= 0;
    else
        counter <= counter + 1;
end
assign vga_clk = counter[0];
assign snake_clk = counter[25];
//game control
always@(posedge CLK)begin
    if(RESET)begin
        gg<=0;
    end
    else if(x1 >= 375 || x1 <= -375 || y1 >= 225 || y1 <= -275)
        gg<=1;
    else
        gg<=0;
end
//sanke control
always @(posedge snake_clk) begin
    if (RESET)begin
        y1<=0;
        y2<=0;
        y3<=0;
        y4<=0;
        y5<=0;
        y6<=0;
        y7<=0;
        y8<=0;
        y9<=0;
        y10<=0;
        x1<=4*`R;
        x2<=3*`R;
        x3<=2*`R;
        x4<=`R;
        x5<=0;
        x6<=-`R;
        x7<=-2*`R;
        x8<=-3*`R;
        x9<=-4*`R;
        x10<=-5*`R;
    end
        else begin
        case(g_c_state)
            `IDLE:begin
                y1<=0;
                y2<=0;
                y3<=0;
                y4<=0;
                y5<=0;
                y6<=0;
                y7<=0;
                y8<=0;
                y9<=0;
                y10<=0;
                x1<=4*`R;
                x2<=3*`R;
                x3<=2*`R;
                x4<=`R;
                x5<=0;
                x6<=-`R;
                x7<=-2*`R;
                x8<=-3*`R;
                x9<=-4*`R;
                x10<=-5*`R;
            end
            `PLAY:begin
                y1<=0;
                y2<=0;
                y3<=0;
                y4<=0;
                y5<=0;
                y6<=0;
                y7<=0;
                y8<=0;
                y9<=0;
                y10<=0;
                x1<=4*`R;
                x2<=3*`R;
                x3<=2*`R;
                x4<=`R;
                x5<=0;
                x6<=0;
                x7<=0;
                x8<=0;
                x9<=0;
                x10<=0;
            end
            `RIGHT:begin
                x1<=x1+`Space;
                x2<=x1;
                x3<=x2;
                x4<=x3;
                x5<=x4;
                x6<=x5;
                x7<=x6;
                x8<=x7;
                x9<=x8;
                x10<=x9;
                y1<=y1;
                y2<=y1;
                y3<=y2;
                y4<=y3;
                y5<=y4;
                y6<=y5;
                y7<=y6;
                y8<=y7;
                y9<=y8;
                y10<=y9;
            end
            `LEFT:begin
                x1<=x1-`Space;
                x2<=x1;
                x3<=x2;
                x4<=x3;
                x5<=x4;
                x6<=x5;
                x7<=x6;
                x8<=x7;
                x9<=x8;
                x10<=x9;
                y1<=y1;
                y2<=y1;
                y3<=y2;
                y4<=y3;
                y5<=y4;
                y6<=y5;
                y7<=y6;
                y8<=y7;
                y9<=y8;
                y10<=y9;
            end
            `UP:begin
                x1<=x1;
                x2<=x1;
                x3<=x2;
                x4<=x3;
                x5<=x4;
                x6<=x5;
                x7<=x6;
                x8<=x7;
                x9<=x8;
                x10<=x9;
                y1<=y1+`Space;
                y2<=y1;
                y3<=y2;
                y4<=y3;
                y5<=y4;
                y6<=y5;
                y7<=y6;
                y8<=y7;
                y9<=y8;
                y10<=y9;
            end
            `DOWN:begin
                x1<=x1;
                x2<=x1;
                x3<=x2;
                x4<=x3;
                x5<=x4;
                x6<=x5;
                x7<=x6;
                x8<=x7;
                x9<=x8;
                x10<=x9;
                y1<=y1-`Space;
                y2<=y1;
                y3<=y2;
                y4<=y3;
                y5<=y4;
                y6<=y5;
                y7<=y6;
                y8<=y7;
                y9<=y8;
                y10<=y9;
            end
        default:begin
            x1<=x1;
            x2<=x2;
            x3<=x3;
            x4<=x4;
            x5<=x5;
            x6<=x6;
            x7<=x7;
            x8<=x8;
            x9<=x9;
            x10<=x10;
            y1<=y1;
            y2<=y2;
            y3<=y3;
            y4<=y4;
            y5<=y5;
            y6<=y6;
            y7<=y7;
            y8<=y8;
            y9<=y9;
            y10<=y10;
        end
        endcase
    end
end
//food FSM
always @(posedge snake_clk)begin
end
//snake FSM
always @(posedge CLK) begin
    if (RESET) begin
        g_n_state<=`IDLE;
    end
    else begin
        case(g_c_state)
            `IDLE:begin
            wen<=1;
                if(BTN_L || BTN_U || BTN_R || BTN_D )begin
                    g_n_state<=`PLAY;
                end
                else  g_n_state<=`IDLE;
            end
            `PLAY:begin
            wen<=1;
                if(gg)g_n_state<=`GG;
                else if(BTN_L)g_n_state<=`RIGHT;
                else if(BTN_R)g_n_state<=`RIGHT;
                else if(BTN_U)g_n_state<=`UP;
                else if(BTN_D)g_n_state<=`DOWN;
                else g_n_state<=g_c_state;
            end
            `RIGHT:begin
            wen<=1;
                if(gg)g_n_state<=`GG;
                else if(BTN_L)g_n_state<=`RIGHT;
                else if(BTN_R)g_n_state<=`RIGHT;
                else if(BTN_U)g_n_state<=`UP;
                else if(BTN_D)g_n_state<=`DOWN;
                else g_n_state<=g_c_state;
            end
            `LEFT:begin
            wen<=1;
                if(gg)g_n_state<=`GG;
                else if(BTN_L)g_n_state<=`LEFT;
                else if(BTN_R)g_n_state<=`LEFT;
                else if(BTN_U)g_n_state<=`UP;
                else if(BTN_D)g_n_state<=`DOWN;
                else g_n_state<=g_c_state;
            end
            `UP:begin
            wen<=1;
                if(gg)g_n_state<=`GG;
                else if(BTN_L)g_n_state<=`LEFT;
                else if(BTN_R)g_n_state<=`RIGHT;
                else if(BTN_U)g_n_state<=`UP;
                else if(BTN_D)g_n_state<=`UP;
                else g_n_state<=g_c_state;
            end
        `DOWN:begin
            wen<=1;
            if(gg)g_n_state<=`GG;
            else if(BTN_L)g_n_state<=`LEFT;
            else if(BTN_R)g_n_state<=`RIGHT;
            else if(BTN_U)g_n_state<=`DOWN;
            else if(BTN_D)g_n_state<=`DOWN;
            else g_n_state<=g_c_state;
        end
        `GG:begin
            wen<=0;
            g_n_state<=`GG;
        end
        default:begin
            wen <= 0;
            g_n_state <= g_n_state;
        end
        endcase
    end
end

    //////////////// draw color ///////////////////////////
    always@(posedge CLK)begin
        if(RESET)begin
            x_m<=0;
            y_m<=0;
            refill_done<=0;
        end
        else if(x_m<799 && y_m<600)begin //important! y_m<600
            x_m <= x_m + 1'b1;
            y_m <= y_m;
            refill_done<=0;
        end
        else if(x_m==799 && y_m<600)begin
            y_m <= y_m + 1'b1;
            x_m <= 0;
            refill_done<=0;
        end
        else begin
            x_m <= 0;
            y_m <= 0;
            refill_done<=1;
        end
    end

    ////////////////////save color/////////////////
    always@(posedge CLK)begin
        if(RESET)begin
            color_r<=0;
            color_g<=0;
            color_b<=0;
        end
        else
        begin if((x-x1)*(x-x1)+(y-y1)*(y-y1)< `Area)begin
                color_r<=0;
                color_g<=1;
                color_b<=0;
            end
            else if((x-x2)*(x-x2)+(y-y2)*(y-y2)<`Area)begin
                color_r<=0;
                color_g<=1;
                color_b<=0;
            end
            else if((x-x3)*(x-x3)+(y-y3)*(y-y3)<`Area)begin
                color_r<=0;
                color_g<=1;
                color_b<=0;
            end
            else if((x-x4)*(x-x4)+(y-y4)*(y-y4)<`Area)begin
                color_r<=0;
                color_g<=1;
                color_b<=0;
            end
            else if((x-x5)*(x-x5)+(y-y5)*(y-y5)<`Area)begin
                color_r<=0;
                color_g<=1;
                color_b<=0;
            end
            else if((x-x6)*(x-x6)+(y-y6)*(y-y6)<`Area)begin
                color_r<=0;
                color_g<=1;
                color_b<=0;
            end
            else if((x-x7)*(x-x7)+(y-y7)*(y-y7)<`Area)begin
                color_r<=0;
                color_g<=1;
                color_b<=0;
            end
            else if((x-x8)*(x-x8)+(y-y8)*(y-y8)<`Area)begin
                color_r<=0;
                color_g<=1;
                color_b<=0;
            end
            else if((x-x9)*(x-x9)+(y-y9)*(y-y9)<`Area)begin
                color_r<=0;
                color_g<=1;
                color_b<=0;
            end
            else if((x-x10)*(x-x10)+(y-y10)*(y-y10)<`Area)begin
                color_r<=0;
                color_g<=1;
                color_b<=0;
            end
            else if( x > -375 && x < 375 && y > -275 && y < 225 )begin
                color_r<=0;
                color_g<=0;
                color_b<=0;
            end
            else begin
                color_r<=1;
                color_g<=1;
                color_b<=1;
            end
        end
    end
    ////////////////////////////////////

    assign x=x_m - (`Width / 2);
    assign y=(`Height/2) - y_m;
    assign addr_w=y_m*`Width+x_m;
    assign vga_addr=vga_y*`Width+vga_x;
    ///////////////// block memory 800x600 //////////////////////////////////////

    blk_mem_gen_v7_3 mem(
        .clka(CLK),
        .wea(wen),
        .addra(addr_w),
        .dina({color_r,color_g,color_b}),
        .douta(out_a),

        .clkb(CLK),
        .web(1'b0), // I am b ,I don't write
        .addrb(vga_addr),
        .dinb(6'd0),
        .doutb(rgb_data) //rgb data out to vga_out module
    );

    ///////////////// vga_out ///////////////////////////////////////////////////

    wire vag_clk_p,vga_clk_n; //useless
    wire vga_h_out,vga_v_out;

    wire [11:0]vga_x;
    wire [11:0]vga_y;
    wire rst_n;
    assign rst_n = ~RESET;
    vga_out out(
        .clk_fpga(vga_clk),
        .rst_n(rst_n),
        .vga_clk_p(vga_clk_p),
        .vga_clk_n(vga_clk_n),
        .vga_h_out(vga_h_out),
        .vga_v_out(vga_v_out),
        .vga_data(vga_data_w), // RGB data
        .x(vga_x),
        .y(vga_y),
        .rgb_data(rgb_data) //data in
    );
    always@(posedge CLK)begin
        if(RESET)begin
            vga_h_out_r<=1'b0;
            vga_v_out_r<=1'b0;
            g_c_state<=`IDLE;
        end
        else begin
            vga_h_out_r<=vga_h_out;
            vga_v_out_r<=vga_v_out;
            g_c_state<=g_n_state;
        end
    end

    endmodule
