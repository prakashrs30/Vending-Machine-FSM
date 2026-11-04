module vending_top (
    input  clk,
    input  rst,
    input  [7:0]money_in,
    input  money_valid,
    input  cancel_btn,
    input  drop_sensor,
    input  [2:0]item_select,
    input  select_item,
    input  admin_mode,
    input  set_price_btn,
    input  [2:0]admin_item_id,
    input  [7:0]new_price_in,
    output coin_return,
    output jam_alarm,
    output [2:0]state_out,
    output [7:0]balance_out,
    output [6:0]dispense_motor,
    output [3:0]an,
    output [6:0]seg
);
    wire clk_1hz;
    wire [7:0]change_val;
    timer100Mto1 u_timer (
        .org100M (clk),
        .rst(rst),
        .out1(clk_1hz)
    );
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
    seven_seg_display u_display (
        .clk(clk),
        .rst(rst),
        .val_in(change_val),
        .an(an),
        .seg(seg)
    );

endmodule
