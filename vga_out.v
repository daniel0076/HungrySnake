
//800x600
module vga_out(
	 input clk_fpga,
    input rst_n,
 // input rst,
	 output vga_clk_p,
    output vga_clk_n,
    output vga_h_out,
    output vga_v_out,
    output [11:0] vga_data,
	output reg [11:0] x,
	output reg [11:0] y,
    input [5:0] rgb_data
    );
	 
wire rst1=!rst_n;

/*
//DVI clock generation
diff_clk_gen diff_clk_gen_i(
    .clk_in     (clk_fpga),
	 .rst_in     (rst1),
	 .clk0_out   (vga_clk_p),
	 .clk180_out (vga_clk_n)
);
*/

	assign vga_clk_p = clk_fpga;
	assign vga_clk_n = ~clk_fpga;

reg vga_hs;
reg vga_vs;			
/*
//800x600, 60Hz, clk=40MHz

parameter h_front=40;
parameter h_syn=128;
parameter h_back=88;
parameter h_act=800;

parameter v_front=1;
//parameter v_syn=9;
//parameter v_back=18;
parameter v_syn=4;
parameter v_back=23;
parameter v_act=600;
reg [23:0] rgb_data0;
*/

//800x600, 75Hz, clk=49.5MHz

parameter h_front=16;
parameter h_syn=80;
parameter h_back=160;
parameter h_act=800;

parameter v_front=1;
parameter v_syn=3;
parameter v_back=21;
parameter v_act=600;
reg [5:0] rgb_data0;


always@(posedge clk_fpga or negedge rst_n)
if(!rst_n) rgb_data0<=6'h0;
else rgb_data0<=rgb_data;



reg [11:0] h_count;
reg h_action;
always@(posedge clk_fpga or negedge rst_n)
if(!rst_n)
	begin
	h_count<=12'b0;
	vga_hs<=1'b1;
	h_action<=1'b0;
	end
else
	begin
	if(h_count<=h_front+h_syn+h_back+h_act-2)
		h_count<=h_count+1'b1;
	else
		begin
		h_count<=12'b0;
		h_action<=1'b0;
		end
	if(h_count==h_front-1)
		vga_hs<=1'b0;
	else if(h_count==h_front+h_syn-1)
		vga_hs<=1'b1;
	if(h_count==h_front+h_syn+h_back-1)
		h_action<=1'b1;		
	end
	

reg [9:0] v_count;
reg v_action;
always@(posedge vga_hs or negedge rst_n)
if(!rst_n)
	begin
	v_count<=10'b0;
	vga_vs<=1'b1;
	v_action<=1'b0;
	end
else
	begin
	if(v_count<=v_front+v_syn+v_back+v_act-2)
		v_count<=v_count+1'b1;
	else
		begin
		v_count<=10'b0;
		v_action<=1'b0;
		end
	if(v_count==v_front-1)
		vga_vs<=1'b0;
	else if(v_count==v_front+v_syn-1)
		vga_vs<=1'b1;
	if(v_count==v_front+v_syn+v_back-1)
		v_action<=1'b1;
	end
	
	
//x, y for block memory
//reg [11:0] x;
//reg [11:0] y;

always@(h_count or v_count)
begin
	if(h_count >= h_front+h_syn+h_back-1)
		x = h_count - (h_front+h_syn+h_back-1);
	else
		x = 0;
	if(v_count>=v_front+v_syn+v_back-1)
		y = v_count - (v_front+v_syn+v_back-1);
	else
		y = 0;
end
	

assign vga_h_out=vga_hs;
assign vga_v_out=vga_vs;

wire vga_de_out;

assign vga_de_out=h_action&v_action;
wire [11:0] rgb_data1;
assign rgb_data1=(clk_fpga==1'b1)?{rgb_data0[5:4],rgb_data0[5:4],rgb_data0[3:2],rgb_data0[3:2],rgb_data0[1:0],rgb_data0[1:0]}:12'd0;

reg [31:0]count_w,count_r;

always@(posedge clk_fpga or negedge rst_n)begin
  if(!rst_n)begin
    count_r <= 31'b0;
  end
  else begin
    count_r <= count_w;
  end
end
//jay
/*
always@(*)begin
  count_w = count_r + 1'b1;
end

always@(*)begin
  if(valid)
    count_w = {rgb_data,20'b0};
  else
    count_w = count_r;
end
*/

//for test
assign vga_data=vga_de_out?(rgb_data1):12'h0;
//assign vga_data=vga_de_out?{rgb_data[23:20],rgb_data[15:12],rgb_data[7:4]}:12'h0;
//assign vga_data=vga_de_out?{12'hf2a0}:12'h0;
//assign vga_data=vga_de_out?{count_r[31:20]}:12'h0;
//assign vga_data=vga_de_out?12'hfff:12'h000;
endmodule
