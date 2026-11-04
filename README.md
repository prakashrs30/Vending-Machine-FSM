#  Smart 7-Item Vending Machine Controller in Verilog (FPGA)

A complete, production-grade **Finite State Machine with Datapath (FSMD)** implementing a smart, multi-item vending machine controller in synthesizable Verilog HDL. Designed, synthesized, and verified on the **AMD / RealDigital Boolean Board (Spartan-7 XC7S50-CSGA324)**.

---

## 🌟 Key Features

1. **Finite State Machine with Datapath (FSMD):**
   - Clean 7-state control path coordinating an 8-bit arithmetic datapath.
   - Real-time balance accumulation, price comparison, and change computation.

2. **7-Item Place Allocation & Independent Motors:**
   - On-chip memory array (`price_table [0:6]`) storing individual prices for 7 different slots.
   - Dedicated 7-bit one-hot motor outputs (`dispense_motor [6:0]`) driving individual dispensing coils.

3. **Owner / Admin Maintenance Mode (VIO Integration):**
   - Allows the machine owner to enter maintenance mode and dynamically reprice any slot (0 to 6) at runtime without reprogramming the FPGA.
   - Interfaced with Xilinx **Virtual Input/Output (VIO)** core for live parameter tweaking from a PC dashboard.

4. **Dual Real-Time Timers (1 Hz Prescaler):**
   - **Inactivity Timeout (12s):** Automatically cancels and refunds money if a customer walks away without selecting an item.
   - **Jam Watchdog Timer (4s):** Monitors physical dispensing; halts motor and alarms if an item is stuck.

5. **Environmental Feedback (Optical Drop Sensor):**
   - Employs an IR optical chute sensor (`drop_sensor`) to verify that the item physically fell before finalizing the purchase. If a jam occurs, the full amount is safely refunded.

6. **Multiplexed 7-Segment Display Controller:**
   - Active-low common-anode display driver refreshing at ~380 Hz (flicker-free).
   - Real-time decimal decoding displaying the exact change returned (`change_out`).

---

### State Encoding Table

| State Name | Binary Code | Description |
| :--- | :---: | :--- |
| **`s_idle`** | `3'b000` | Waiting for customer or owner |
| **`s_accept`** | `3'b001` | Accumulating balance; inactivity timer ticking |
| **`s_dispense`** | `3'b010` | Specific slot motor ON; watchdog timer running |
| **`s_change`** | `3'b011` | Dispensing change (`balance - price_table[selected_item]`) |
| **`s_refund`** | `3'b100` | Returning full deposited money |
| **`s_jam_error`** | `3'b101` | Flagging motor jam alarm; prepares emergency refund |
| **`s_config`** | `3'b110` | Owner admin mode (reprogramming item prices) |

---

## 📁 Repository Structure

```text
├── rtl/
│   ├── vending.v             # Core FSMD vending machine controller
│   ├── timer100Mto1.v        # 100 MHz to 1 Hz clock prescaler
│   ├── seven_seg_display.v   # Multiplexed 7-segment display driver
│   └── vending_top.v         # Top-level module integrating RTL & peripherals
├── tb/
│   └── vending_tb.v          # Self-checking testbench (4 comprehensive scenarios)
├── constrs/
│   └── boolean_vending.xdc   # Physical pin constraints for AMD Boolean Board
└── README.md
```

---

<img width="500" alt="Boolean control pins" src="https://github.com/user-attachments/assets/a31bc16c-4930-4f3f-b3bd-779cf270d32c" />

---
## Waveform


<img width="1000" alt="Waveform" src="https://github.com/user-attachments/assets/a9900899-d910-4217-b51e-d33809b45583" />

## 🎮 Hardware Pin Mapping (AMD Boolean Board)

| Signal Name | FPGA Pin | I/O Standard | Peripheral Component |
| :--- | :---: | :---: | :--- |
| `clk` | **F14** | `LVCMOS33` | 100 MHz Onboard MEMS Oscillator |
| `rst` | **L1** | `LVCMOS33` | Pushbutton (Active-High Reset) |
| `select_item` | **J1** | `LVCMOS33` | Pushbutton (Purchase confirm) |
| `money_valid` | **H2** | `LVCMOS33` | Pushbutton (Enter money strobe) |
| `cancel_btn` | **J2** | `LVCMOS33` | Pushbutton (Cancel / Refund) |
| `drop_sensor` | **J5** | `LVCMOS33` | Pushbutton / External IR Beam Sensor |
| `admin_mode` | **K1** | `LVCMOS33` | Slide Switch (Admin toggle) |
| `set_price_btn` | **K2** | `LVCMOS33` | Pushbutton (Save new price) |
| `money_in[7:0]` | **N2..U1** | `LVCMOS33` | Slide Switches `SW[7:0]` |
| `item_select[2:0]` | **M1..N1** | `LVCMOS33` | Slide Switches `SW[10:8]` |
| `balance_out[7:0]` | **B2..F2** | `LVCMOS33` | Output LEDs `LD[7:0]` |
| `state_out[2:0]` | **A3..A2** | `LVCMOS33` | Output LEDs (State monitor) |
| `coin_return` | **B4** | `LVCMOS33` | LED (Coin return active) |
| `jam_alarm` | **A4** | `LVCMOS33` | LED (Motor jam alert) |
| `seg[6:0]` | **B5..D7** | `LVCMOS33` | 7-Segment Display Cathodes (`g` to `a`) |
| `an[3:0]` | **A8..D5** | `LVCMOS33` | 7-Segment Display Anodes (`AN3` to `AN0`) |

---

## 🧪 Simulation & Verification Scenarios

The testbench (`vending_tb.v`) verifies all corner cases in cycle-accurate simulation:

1. **Scenario 1 (Admin Repricing):** Owner activates Admin Mode, selects Slot 1 (Soda), and updates price from default ₹15 to ₹25.
2. **Scenario 2 (Normal Purchase with Change):** Customer inserts ₹30, selects Slot 1. Motor 1 turns ON, drop sensor triggers, and ₹5 change is calculated and outputted.
3. **Scenario 3 (Inactivity Timeout):** Customer deposits ₹20 and walks away. After 12 cycles, the machine automatically executes an emergency refund of the full ₹20.
4. **Scenario 4 (Motor Jam Watchdog Protection):** Customer buys Slot 3 (Chips). Motor 3 turns ON, but the item gets physically stuck (sensor stays low). After 4 cycles, the watchdog trips, sounds the jam alarm, and safely refunds the customer's ₹50.

---
3. **Add Constraints:**  
   Add `boolean_vending.xdc` under Constraints.
4. **Synthesize & Implement:**  
   Click **Generate Bitstream**.
5. **Program Board:**  
   Connect the AMD Boolean board via micro-USB $\rightarrow$ *Open Hardware Manager* $\rightarrow$ *Auto Connect* $\rightarrow$ *Program Device*.
