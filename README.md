Verilog貪吃蛇
===
### Module 說明
+ 開發板
    + 使用Zedboard Zynq z7020
    + CPU:CLG484
    + speed:-1
    + System Clock:100MHz
+ vga_design.v
    + 貪吃蛇主要module
+ vga_out.v
    + VGA輸出module
    + Resolutin:800x600@75Hz
+ score_board.v
    + 計分板模組
+ memory
    + 畫面色彩memory
        + 800x600x6 bits
    + 計分板數字pattern
        + Unknown
+ .ucf為接線配置檔
    + 上下左右控制蛇身
    + 中鍵為RESET
    + SW[0]切換青蛇或白蛇

### Screen Shot
+ coming soon

### Cowokers
+ Ellis Teng
+ Jeff Huang
+ Yujun Wang
+ Daniel Tsai
