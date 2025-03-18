`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (input basys_clock, btnL, btnU, btnC, btnR, btnD, input [15:0] sw, output [15:0] led, output [7:0] JB, output [3:0] anode, output [7:0] segment);
            

    wire fb;
    wire [12:0] pixel_index;
    wire [6:0] x_coordinate, y_coordinate;
    wire sending_pixels;
    wire sample_pixel;
    reg [15:0] oled_colour = 16'b00000_000000_00000;
    
    wire clk_6p25MHz;
    
    flexible_clock_divider unit_6p25MHz_clock(.basys_clock(basys_clock), .count_up_to(7), .new_clock(clk_6p25MHz));
    
    Oled_Display(
    .clk(clk_6p25MHz), .reset(0), .frame_begin(fb), .sending_pixels(sending_pixels), 
    .sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(oled_colour), 
    .cs(JB[0]), .sdin(JB[1]), .sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7])
    );
    
    led_unit LED(.basys_clk(basys_clock), .sw(sw),.led(led), .btnU(btnU),.btnC(btnC),.anode(anode),.segment(segment));
endmodule