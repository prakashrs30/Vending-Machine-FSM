`timescale 1ns / 1ps

module vending_top (
    input  clk,            // 100 MHz (F14)
    input  rst,            // Button J1 (Active-High)
    input  [7:0]money_in,       // Switches
    input  money_valid,    // Button H2
    input  cancel_btn,     // Button J2
    input  drop_sensor,    // Pin J5
    input  [2:0]item_select,    // Switches
    input  select_item,    // Button L1
    input  admin_mode,     // Switch K1
    input  set_price_btn,  // Button K2

    // VIO Inputs (controlled via your VIO core)
    input  [2:0]admin_item_id,  // from VIO
    input  [7:0]new_price_in,   // from VIO

    // Outputs
    output coin_return,    // LED B4
    output jam_alarm,      // LED A4
    output [2:0]state_out,      // LEDs A3, B3, A2
    output [7:0]balance_out,    // LEDs B2..F2
    output [6:0]dispense_motor, // to VIO probe / LEDs
    
    // 7-Segment Display Pins for change_out
    output [3:0]an,             // Anodes
    output [6:0]seg             // Cathodes
);

    wire clk_1hz;
    wire [7:0]change_val;

    // 1. 100 MHz -> 1 Hz Timer (Active-High rst)
    timer100Mto1 u_timer (
        .org100M (clk),
        .rst(rst),
        .out1(clk_1hz)
    );

    // 2. Vending Machine FSM (Active-High rst)
    vending u_vending (
        .clk(clk_1hz),
        .rst(rst),
        .money_in(money_in),
        .money_valid(money_valid),
        .cancel_btn(cancel_btn),
        .drop_sensor(drop_sensor),
        .coin_return(coin_return),
        .change_out(change_val),
        .balance_out(balance_out),
        .jam_alarm (jam_alarm),
        .state_out(state_out),
        .item_select(item_select),
        .select_item(select_item),
        .admin_mode(admin_mode),
        .admin_item_id(admin_item_id),
        .new_price_in(new_price_in),
        .set_price_btn(set_price_btn),
        .dispense_motor(dispense_motor)
    );

    // 3. 7-Segment Driver (Displays change_val)
    seven_seg_display u_display (
        .clk(clk),
        .rst(rst),
        .val_in(change_val),
        .an(an),
        .seg(seg)
    );

endmodule
