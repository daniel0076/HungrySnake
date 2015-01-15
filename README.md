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
    + SW7作為開關(0: RESET=1)
    + 上下左右控制蛇身
    + SW0切換遊戲暫停或開始（1: 暫停）
    + {SW2,SW1}控制蛇的速度
        + 00: 1Hz
        + 01: 1.2Hz
        + 10: 1.5Hz
        + 11: 2Hz
    + SW6切換青蛇或白蛇

### Screen Shot
+ coming soon

### Cowokers
+ Ellis Teng
+ Jeff Huang
+ Yujun Wang
+ Daniel Tsai
