`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2025 18:25:58
// Design Name: 
// Module Name: led_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module led_unit(
    input basys_clk,
    input [15:0] sw, 
    input btnU, btnC,  
    output reg [3:0] anode,
    output reg [15:0] led, 
    output reg [7:0] segment
);

    reg [1:0] current_anode = 0;
    reg [31:0] counter_3ms = 15000;

    wire clk_3ms;
    flexible_clock_divider unit_3ms_clock(.basys_clock(basys_clk), .count_up_to(counter_3ms), .new_clock(clk_3ms));

    // Countdown timer logic
    reg [6:0] timer_sec = 0;
    reg [26:0] one_sec_counter = 0;
    wire one_sec_pulse = (one_sec_counter == 99_999_999); // 1 second @100MHz
    reg counting_down = 0;

    // Button debounce for btnU
    reg [15:0] btnU_history = 0;
    reg btnU_pressed = 0;

    reg blinking = 0;

    always @(posedge basys_clk) begin
        btnU_history <= {btnU_history[14:0], btnU};
        
        if (btnU_history == 16'hFFFF && !btnU_pressed) begin
            btnU_pressed <= 1;
            counting_down <= 0;
            timer_sec <= 0;
            blinking <= 1;
        end else if (btnU_history == 16'h0000) begin
            btnU_pressed <= 0;
        end

        if ((sw[0] || sw[1]) && !counting_down && !blinking) begin
            timer_sec <= sw[0] ? 60 : 120;
        end

        if (btnC && !counting_down && (sw[0] || sw[1]) && !blinking) begin
            counting_down <= 1;
        end

        if (!sw[0] && !sw[1]) begin
            timer_sec <= 0;
            counting_down <= 0;
            blinking <= 0;
        end else if (one_sec_pulse && timer_sec > 0 && counting_down) begin
            timer_sec <= timer_sec - 1;
        end

        if (timer_sec == 0)
            counting_down <= 0;

        one_sec_counter <= (one_sec_pulse || !counting_down) ? 0 : one_sec_counter + 1;
    end

    // 10 Hz blinking LEDs
    reg [23:0] led_blink_counter = 0;

    always @(posedge basys_clk) begin
        if (blinking) begin
            if (led_blink_counter >= 4_999_999) begin // 10Hz blinking
                led <= ~led;
                led_blink_counter <= 0;
            end else
                led_blink_counter <= led_blink_counter + 1;
        end else begin
            led <= 0;
            led_blink_counter <= 0;
        end
    end

    // Display multiplexing (7-seg)
    reg [3:0] digit[3:0];

    always @(posedge clk_3ms) begin
        current_anode <= current_anode + 1;

        digit[0] <= (timer_sec / 1000) % 10;
        digit[1] <= (timer_sec / 100) % 10;
        digit[2] <= (timer_sec / 10) % 10;
        digit[3] <= timer_sec % 10;

        case (current_anode)
            2'b00: begin anode <= 4'b0111; segment <= digit_to_segment(digit[0]); end
            2'b01: begin anode <= 4'b1011; segment <= digit_to_segment(digit[1]); end
            2'b10: begin anode <= 4'b1101; segment <= digit_to_segment(digit[2]); end
            2'b11: begin anode <= 4'b1110; segment <= digit_to_segment(digit[3]); end
        endcase
    end

    // Digit to 7-segment converter
    function [7:0] digit_to_segment(input [3:0] digit);
        case(digit)
            4'd0: digit_to_segment = 8'b11000000;
            4'd1: digit_to_segment = 8'b11111001;
            4'd2: digit_to_segment = 8'b10100100;
            4'd3: digit_to_segment = 8'b10110000;
            4'd4: digit_to_segment = 8'b10011001;
            4'd5: digit_to_segment = 8'b10010010;
            4'd6: digit_to_segment = 8'b10000010;
            4'd7: digit_to_segment = 8'b11111000;
            4'd8: digit_to_segment = 8'b10000000;
            4'd9: digit_to_segment = 8'b10010000;
            default: digit_to_segment = 8'b11111111;
        endcase
    endfunction

endmodule




