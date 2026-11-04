`timescale 1ns / 1ps

module vending(
    input clk,
    input rst,
    input [7:0]money_in,
    input money_valid,
    input cancel_btn,
    input drop_sensor,
    output reg coin_return,
    output reg [7:0]change_out,
    output reg [7:0]balance_out,
    output reg jam_alarm,
    output [2:0]state_out,
    input [2:0]item_select,
    input select_item,
    input admin_mode,
    input [2:0]admin_item_id,
    input [7:0]new_price_in,
    input set_price_btn,
    output reg [6:0]dispense_motor
);
    localparam timeout_inactivity=4'b1100;
    localparam timeout_watchdog=4'b0100;
    localparam s_idle=3'b000;
    localparam s_accept=3'b001;
    localparam s_dispense=3'b010;
    localparam s_change=3'b011;
    localparam s_refund=3'b100;
    localparam s_jam_error        = 3'b101;
    localparam s_config           = 3'b110;
    reg [7:0]balance;
    reg [3:0]timer_count;
    reg [2:0]current_state,next_state;
    reg [2:0]selected_item;
    reg [7:0]price_table[6:0];
    assign state_out=current_state;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timer_count <= 4'b0;
        end
        else if ((current_state != next_state) || money_valid) begin
            timer_count <= 4'b0;
        end
        else begin
            timer_count <= timer_count + 1'b1;
        end
    end
    // 2. Balance, Change & Price Table
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            balance<= 8'b0;
            change_out<= 8'b0;
            selected_item<= 3'b0;
            price_table[0]<= 8'd10;
            price_table[1]<= 8'd15;
            price_table[2]<= 8'd20;
            price_table[3]<= 8'd25;
            price_table[4]<= 8'd30;
            price_table[5]<= 8'd35;
            price_table[6]<= 8'd40;
        end
        else begin
            if ((current_state == s_config) && set_price_btn && (admin_item_id <= 3'd6)) begin
                price_table[admin_item_id] <= new_price_in;
            end
            case (current_state)
                s_idle: begin
                    change_out <= 8'b0;
                    if (money_valid) begin
                        balance <= balance + money_in;
                    end
                end
                s_accept: begin
                    if (money_valid) begin
                        balance <= balance + money_in;
                    end
                    if (select_item && (item_select <= 3'd6)) begin
                        selected_item <= item_select;
                    end
                end
                s_change: begin
                    change_out <= balance - price_table[selected_item];
                    balance    <= 8'b0;
                end
                s_refund: begin
                    change_out <= balance;
                    balance    <= 8'b0;
                end
                default: begin
                    balance <= balance;
                end
            endcase
        end
    end

    // 3. State Block 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= s_idle;
        end
        else begin
            current_state <= next_state;
        end
    end

    // 4. Next State Logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            s_idle: begin
                if (admin_mode)
                    next_state = s_config;
                else if (money_valid)
                    next_state = s_accept;
                else
                    next_state = s_idle;
            end
            s_accept: begin
                if (cancel_btn)
                    next_state = s_refund;
                else if (timer_count >= timeout_inactivity)
                    next_state = s_refund;
                else if (select_item && (item_select <= 3'd6)) begin
                    if (balance >= price_table[item_select])
                        next_state = s_dispense;
                    else
                        next_state = s_accept;
                end
                else
                    next_state = s_accept;
            end
            s_dispense: begin
                if (drop_sensor)
                    next_state = s_change;
                else if (timer_count >= timeout_watchdog)
                    next_state = s_jam_error;
                else
                    next_state = s_dispense;
            end
            s_change:    next_state = s_idle;
            s_refund:    next_state = s_idle;
            s_jam_error: next_state = s_refund;
            s_config: begin
                if (!admin_mode)
                    next_state = s_idle;
                else
                    next_state = s_config;
            end
            default: next_state = s_idle;
        endcase
    end

    // 5. Output Logic
    always @(*) begin
        dispense_motor = 7'b0;
        coin_return    = 1'b0;
        jam_alarm      = 1'b0;
        balance_out    = balance;
        case (current_state)
            s_idle, s_accept, s_config: begin
                dispense_motor = 7'b0;
                coin_return    = 1'b0;
                jam_alarm      = 1'b0;
            end
            s_dispense: begin
                dispense_motor[selected_item] = 1'b1;
                coin_return                   = 1'b0;
                jam_alarm                     = 1'b0;
            end
            s_change, s_refund: begin
                dispense_motor = 7'b0;
                coin_return    = 1'b1;
                jam_alarm      = 1'b0;
            end
            s_jam_error: begin
                dispense_motor = 7'b0;
                coin_return    = 1'b0;
                jam_alarm      = 1'b1;
            end
            default: begin
                dispense_motor = 7'b0;
                coin_return    = 1'b0;
                jam_alarm      = 1'b0;
            end
        endcase
    end
endmodule
