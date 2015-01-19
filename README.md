Hungry Snake by Verilog
===
### Module Description
+ FPGA Board
    + Zedboard Zynq z7020
    + CPU:CLG484
    + speed:-1
    + System Clock:100MHz
+ vga_design.v
    + Main module of Hungry Snake
+ vga_out.v
    + VGA out module
    + Resolutin:800x600@75Hz
+ score_board.v
    + The score board module
    + Using memory digit patterns
+ Block Memory
    + Screen color memory
        + 800x600x6 bits RGB
    + Digit pattern memory
        + 80x60x10 bits
+ How to play
    + SW7 is the RESET switch
        + SW7=0 : RESET
        + SW7=1 : Play
    + Use the four direction buttons to control the snake
    + SW0 is the Pause switch
        + SW0=0 : Play
        + SW0=1 : Pause
    + {SW2,SW1} Can change the speed of the snake
        + 2'b00: 1.5Hz
        + 2'b01: 2Hz
        + 2'b10: 3Hz
        + 2'b11: 4Hz
    + SW6 switch the color of the snake
        + SW6=0 : green snake
        + SW6=1 : white snake
    + Death control
        #### If you hit the wall or the obtacle, you will die

### Screen Shots
![FPGA](https://raw.githubusercontent.com/daniel0076/HungrySnake/master/screenshot/board.jpg)
![welcome](https://raw.githubusercontent.com/daniel0076/HungrySnake/master/screenshot/welcome.jpg)
![gameplay1](https://raw.githubusercontent.com/daniel0076/HungrySnake/master/screenshot/gameplay1.jpg)
![gameplay2](https://raw.githubusercontent.com/daniel0076/HungrySnake/master/screenshot/gameplay2.jpg)
![GG](https://raw.githubusercontent.com/daniel0076/HungrySnake/master/screenshot/GG.jpg)

### Cowokers
+ Ellis Teng
+ Jeff Huang(Dinglet)
+ Yujun Wang(YuJunWang)
+ Daniel Tsai(daniel0076)
