`timescale 1ns / 1ps

module seven_seg_display (
    input  wire        clk,        // 100 MHz clock
    input  wire        rst,        // Active-High reset (1 = reset)
    input  wire [7:0]  val_in,     // Connects to change_out
    output reg  [3:0]  an,         // Active-low digit anodes
    output reg  [6:0]  seg         // Active-low cathodes: {g,f,e,d,c,b,a}
);

    wire [3:0] tens_digit  = (val_in / 8'd10) % 10;
    wire [3:0] units_digit = val_in % 8'd10;

    reg [17:0] refresh_counter;
    always @(posedge clk or posedge rst) begin
        if (rst)
            refresh_counter <= 18'd0;
        else
            refresh_counter <= refresh_counter + 1'b1;
    end

    wire active_digit = refresh_counter[17];

    reg [3:0] current_nibble;
    always @(*) begin
        case (active_digit)
            1'b0: begin
                an             = 4'b1110; // Digit 0 ON (Units)
                current_nibble = units_digit;
            end
            1'b1: begin
                an             = 4'b1101; // Digit 1 ON (Tens)
                current_nibble = tens_digit;
            end
            default: begin
                an             = 4'b1111;
                current_nibble = 4'd0;
            end
        endcase
    end

    always @(*) begin
        case (current_nibble)
            4'd0: seg = 7'b100_0000;
            4'd1: seg = 7'b111_1001;
            4'd2: seg = 7'b010_0100;
            4'd3: seg = 7'b011_0000;
            4'd4: seg = 7'b001_1001;
            4'd5: seg = 7'b001_0010;
            4'd6: seg = 7'b000_0010;
            4'd7: seg = 7'b111_1000;
            4'd8: seg = 7'b000_0000;
            4'd9: seg = 7'b001_0000;
            default: seg = 7'b111_1111;
        endcase
    end

endmodule
