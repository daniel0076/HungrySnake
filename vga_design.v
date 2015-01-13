`timescale 1ns / 1ps

`define Width 'd800
`define Height 'd600
`define Space 30
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

reg [5:0] s_c_state,s_n_state;
reg [5:0] f_c_state,f_n_state;
reg [5:0] g_c_state,g_n_state;
reg refill_done;
reg gg;
//snake record
reg signed [11:0] x1,x2,x3,x4,x5,x6,x7,x8,x9,x10;
reg signed [11:0] y1,y2,y3,y4,y5,y6,y7,y8,y9,y10;
//food
reg signed [11:0] food_x,food_y;
reg signed [9:0] food_rdm_counter;
reg [5:0] length;
reg eaten;
//socre board
wire dec;
wire gameover;
wire isFilled;
///////////////////// write from here ////////////////////////////////////////
//this is for generic
`define IDLE       'd0
`define PLAY       'd1
`define GG         'd2
`define INIT       'd3
//this is for snake
`define RIGHT       'd4
`define LEFT        'd5
`define UP          'd6
`define DOWN        'd7
// This is for food
`define F_WAIT  'd8
`define F_GEN     'd9
`define F_INIT  'd10
// Drawing FSM

///////////////////// counter /////////////////////////
always @(posedge CLK) begin
    if (RESET)begin
        // reset
        counter <= 0;
    end
    else begin
        counter <= counter + 1;
        if(food_rdm_counter>500)food_rdm_counter<=-500;
        else food_rdm_counter<=food_rdm_counter+1;
    end
end
assign vga_clk = counter[0];
assign snake_clk = counter[24];
//length control
always@(posedge CLK)begin
    if(RESET)begin
        length<=5;
    end
    else if(eaten)begin
        length<=length+1;
    end
    else if(length==10)length<=10;
    else begin
        length<=length;
    end
end
//death control
always@(posedge CLK)begin
    if(RESET)begin
        gg<=0;
    end
    else if((x1 >= 375 || x1 <= -375 || y1 >= 225 || y1 <= -275)
        ||(x1 == x2 && y1 == y2)
        ||(x1 == x3 && y1 == y3)
        ||(x1 == x4 && y1 == y4)
        ||(x1 == x5 && y1 == y5)
        ||(x1 == x6 && y1 == y6)
        ||(x1 == x7 && y1 == y7)
        ||(x1 == x8 && y1 == y8)
        ||(x1 == x9 && y1 == y9)
        ||(x1 == x10 && y1 == y10))begin
        gg<=1;
    end
    else begin
        gg<=0;
    end
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
        x1<=4*`Space;
        x2<=3*`Space;
        x3<=2*`Space;
        x4<=`Space;
        x5<=0;
        x6<=0;
        x7<=0;
        x8<=0;
        x9<=0;
        x10<=0;
    end
        else if(s_c_state==`IDLE || s_c_state == `PLAY) begin
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
                x1<=4*`Space;
                x2<=3*`Space;
                x3<=2*`Space;
                x4<=`Space;
                x5<=0;
                x6<=0;
                x7<=0;
                x8<=0;
                x9<=0;
                x10<=0;
            end
            else begin
                x2<=x1;
                x3<=x2;
                x4<=x3;
                x5<=x4;
                y2<=y1;
                y3<=y2;
                y4<=y3;
                y5<=y4;
                if(length>5)begin
                    x6<=x5;
                    y6<=y5;
                end
                else begin
                    x6<=x4;
                    y6<=y4;
                end
                if(length>6)begin
                    x7<=x6;
                    y7<=y6;
                end
                else begin
                    x7<=x4;
                    y7<=y4;
                end
                if(length>7)begin
                    x8<=x7;
                    y8<=y7;
                end
                else begin
                    x8<=x4;
                    y8<=y4;
                end
                if(length>8)begin
                    x9<=x8;
                    y9<=y8;
                end
                else begin
                    x9<=x4;
                    y9<=y4;
                end
                if(length>9)begin
                    x10<=x9;
                    y10<=y9;
                end
                else begin
                    x10<=x4;
                    y10<=y4;
                end
        case(s_c_state)
            `RIGHT:begin
                x1<=x1+`Space;
                y1<=y1;
            end
            `LEFT:begin
                x1<=x1-`Space;
                y1<=y1;
            end
            `UP:begin
                x1<=x1;
                y1<=y1+`Space;
            end
            `DOWN:begin
                x1<=x1;
                y1<=y1-`Space;
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
always @(posedge CLK)begin
    if(RESET)begin
        food_x <=0;
        food_y <=0;
        eaten<=0;
        f_n_state<=`F_INIT;
    end
    else begin
        case(f_c_state)
            `F_INIT:begin
                food_x <= 1000;
                food_y <= 1000;
                eaten<=0;
                if(BTN_L || BTN_U || BTN_R || BTN_D)begin
                    f_n_state <= `F_WAIT;
                end
                else begin
                    f_n_state<=`F_INIT;
                end
            end
            `F_WAIT:begin
                f_n_state<=`F_WAIT;
                if((x1-food_x)*(x1-food_x)+(y1-food_y)*(y1-food_y)<1225)begin
                    eaten<=1;
                    food_x <= (food_rdm_counter % 16)*`Space;
                    food_y <= (food_rdm_counter % 11)*`Space;
                end
                else if(food_x > 350 || food_x < -350 || food_y > 200 || food_y < -250)begin
                    food_x <= (food_rdm_counter % 16)*`Space;
                    food_y <= (food_rdm_counter % 11)*`Space;
                    eaten<=0;
                end
                else begin
                    food_x<=food_x;
                    food_y<=food_y;
                    eaten<=0;
                end
            end
            default:begin
                food_x<=food_x;
                food_y<=food_y;
                eaten<=0;
                f_n_state<=`F_WAIT;
            end
        endcase
    end
    end
//generic FSM
always@(posedge CLK)begin
    if(RESET)begin
        wen<=0;
        g_n_state=`IDLE;
    end
    else begin
    case(g_c_state)
        `INIT:begin
            wen<=1;
            if(refill_done)begin
                g_n_state=`IDLE;
            end
            else begin
                g_n_state=`INIT;
            end
        end
        `IDLE:begin
            wen<=0;
            if(BTN_L || BTN_U || BTN_R || BTN_D )begin
                g_n_state=`PLAY;
            end
            else  g_n_state=`IDLE;
        end
        `PLAY:begin
            wen<=1;
            if(gg) g_n_state=`GG;
            else g_n_state=`PLAY;
        end
        `GG:begin
            wen<=0;
            g_n_state=`GG;
        end
    endcase
end
end
//snake FSM
always @(posedge CLK) begin
    if(RESET)begin
        s_n_state<=`IDLE;
    end
    else begin
        case(s_c_state)
            `IDLE:begin
                if(BTN_L || BTN_U || BTN_R || BTN_D )begin
                    s_n_state<=`PLAY;
                end
                else  s_n_state<=`IDLE;
            end
            `PLAY:begin
                if(gg)s_n_state<=`GG;
                else if(BTN_L)s_n_state<=`RIGHT;
                else if(BTN_R)s_n_state<=`RIGHT;
                else if(BTN_U)s_n_state<=`UP;
                else if(BTN_D)s_n_state<=`DOWN;
                else s_n_state<=`PLAY;
            end
            `RIGHT:begin
                if(gg)s_n_state<=`GG;
                else if(BTN_U)s_n_state<=`UP;
                else if(BTN_D)s_n_state<=`DOWN;
                else s_n_state<=`RIGHT;
            end
            `LEFT:begin
                if(gg)s_n_state<=`GG;
                else if(BTN_U)s_n_state<=`UP;
                else if(BTN_D)s_n_state<=`DOWN;
                else s_n_state<=`LEFT;
            end
            `UP:begin
                if(gg)s_n_state<=`GG;
                else if(BTN_L)s_n_state<=`LEFT;
                else if(BTN_R)s_n_state<=`RIGHT;
                else s_n_state<=`UP;
            end
        `DOWN:begin
            if(gg)s_n_state<=`GG;
            else if(BTN_L)s_n_state<=`LEFT;
            else if(BTN_R)s_n_state<=`RIGHT;
            else s_n_state<=`DOWN;
        end
        `GG:begin
            s_n_state<=`GG;
        end
        default:begin
            s_n_state <= s_n_state;
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
            color_r<=2'b00;
            color_g<=2'b00;
            color_b<=2'b00;
        end
        else begin
            case(g_c_state)
                `INIT:begin
                    if( x >= -250 && x < -100 && y >= -150 && y < 50 )begin
                        if(x >= -235 && x < -115 && y >= -135 && y < 35 )begin
                            color_r<=2'b01;
                            color_g<=2'b01;
                            color_b<=2'b11;
                        end
                        else begin
                            color_r<=2'b00;
                            color_g<=2'b00;
                            color_b<=2'b11;
                        end
                    end
                    else if ( (x >= -100 && x < 0 && y >= 35 && y < 50)
                        ||(x >= -100 && x < 0 && y >= -130 && y < -115)
                    ||(x >= 0 && x < 250 && y >= -150 && y < -135)
                    ||(x >= 100 && x < 250 && y >= 55 && y < 70)
                    ||(x >= 50 && x < 125 && y >= 135 && y < 150)
                    ||(x >= 0 && x < 50 && y >= 75 && y < 90) ) begin
                        color_r<=2'b00;
                        color_g<=2'b00;
                        color_b<=2'b11;
                    end
                    else if ( (x >= 0 && x < 15 && y >= 35 && y < 75)
                        ||(x >= 0 && x < 15 && y >= -150 && y < -115)
                    ||(x >= 235 && x < 250 && y >= -135 && y < 55)
                    ||(x >= 110 && x < 125 && y >= 55 && y < 150)
                    ||(x >= 50 && x < 65 && y >= 75 && y < 150) ) begin
                        color_r<=2'b00;
                        color_g<=2'b00;
                        color_b<=2'b11;
                    end
                    else if ( (x >= -225 && x < -210 && y >= -275 && y < -175)
                        ||(x >= -225 && x < -135 && y >= -275 && y < -255)
                    ||(x >= -85 && x < -50 && y >= -275 && y < -175) ) begin
                        color_r<=2'b00;
                        color_g<=2'b00;
                        color_b<=2'b11;
                    end
                    else if ( (x >= 0 && x < 15 && y >= -275 && y < -175)
                        ||( x+y+200 < 0 && x+y+210 >= 0 && y >= -275 && y < -225)
                    ||( x-y-240 > 0 && x-y-250 =< 0 && y >= -225 && y < -175) ) begin
                        color_r<=2'b00;
                        color_g<=2'b00;
                        color_b<=2'b11;
                    end
                    else if ( (x >= 120 && x < 135 && y >= -275 && y < -175)
                        ||(x >= 135 && x < 225 && y >= -190 && y < -175)
                    ||(x >= 135 && x < 225 && y >= -240 && y < -215)
                    ||(x >= 135 && x < 225 && y >= -275 && y < -260) ) begin
                        color_r<=2'b00;
                        color_g<=2'b00;
                        color_b<=2'b11;
                    end
                    else begin
                        color_r<=2'b11;
                        color_g<=2'b11;
                        color_b<=2'b11;
                    end
                end
                `PLAY:begin
                    if(((x-x1)*(x-x1)+(y-y1)*(y-y1)< `Area)
                    ||((x-x2)*(x-x2)+(y-y2)*(y-y2) < `Area)
                    ||((x-x3)*(x-x3)+(y-y3)*(y-y3)<`Area)
                    ||((x-x4)*(x-x4)+(y-y4)*(y-y4)<`Area)
                    ||((x-x5)*(x-x5)+(y-y5)*(y-y5)<`Area)
                    ||(length>5 && (x-x6)*(x-x6)+(y-y6)*(y-y6)<`Area)
                    ||(length>6 && (x-x7)*(x-x7)+(y-y7)*(y-y7)<`Area)
                    ||(length>7 && (x-x8)*(x-x8)+(y-y8)*(y-y8)<`Area)
                    ||(length >8 && (x-x9)*(x-x9)+(y-y9)*(y-y9)<`Area)
                    ||(length>9 && (x-x10)*(x-x10)+(y-y10)*(y-y10)<`Area))begin
                        color_r<=2'b00;
                        color_g<=2'b11;
                        color_b<=2'b00;
                    end
                    else if((x-food_x)*(x-food_x)+(y-food_y)*(y-food_y)<225)begin
                        color_r<=2'b11;
                        color_g<=2'b00;
                        color_b<=2'b00;
                    end
                    //for score board so OP
                    else if(x>150 && x <400&& y>220 && y<300)begin
                        if(isFilled)begin
                            color_r<=2'b00;
                            color_g<=2'b00;
                            color_b<=2'b11;
                        end
                        else begin
                            color_r<=2'b11;
                            color_g<=2'b11;
                            color_b<=2'b11;
                        end
                    end
                    else if( x > -375 && x < 375 && y > -275 && y < 220 )begin
                        color_r<=2'b00;
                        color_g<=2'b00;
                        color_b<=2'b00;
                    end
                    else begin
                        color_r<=2'b11;
                        color_g<=2'b11;
                        color_b<=2'b11;
                    end
                end
                default:begin
                        color_r<=color_r;
                        color_g<=color_g;
                        color_b<=color_b;
                end
            endcase
        end
    end


//score_board module

score_board board(
    .clk(CLK), // clock of the fpga (100MHz)
    .reset(RESET),
    .add(eaten), // score will add 1 in a clock cycle if (add==1)
        .decr(dec),
        .gameover(gameover),
        .x_p(x_m), // 12-bit, in screen coordinate
        .y_p(y_m), // 12-bit, in screen coordinate
        .isFilled(isFilled)
    );
//////////////////////////////////

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
        s_c_state<=`IDLE;
        g_c_state<=`INIT;
        f_c_state<=`F_INIT;

    end
    else begin
        vga_h_out_r<=vga_h_out;
        vga_v_out_r<=vga_v_out;
        s_c_state<=s_n_state;
        g_c_state<=g_n_state;
        f_c_state<=f_n_state;
    end
end

endmodule
