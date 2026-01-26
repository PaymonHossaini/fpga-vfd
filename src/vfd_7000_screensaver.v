// GU-7000 Series Screensaver Test
// Sends: 0x1F, 0x28, 0x61, 0x40, 0x03 (All dots on)
// Based on Arduino timing: data setup, WR low 110ns, WR high, 20us delay

module vfd_7000_screensaver (
    input wire clk,           // 27MHz
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire busy,          // Active HIGH when busy
    output reg [5:0] leds
);

    // Timing at 27MHz (37ns per cycle)
    // WR low pulse: ~110ns = 3 cycles minimum, use 8 for safety
    // Post-write delay: 20us = 540 cycles, use 600 for safety
    localparam WR_LOW_CYCLES = 8;
    localparam POST_DELAY_CYCLES = 600;
    localparam BUSY_TIMEOUT = 27_000_000;  // 1 second timeout

    // States
    localparam STATE_INIT       = 4'd0;
    localparam STATE_WAIT_BUSY  = 4'd1;
    localparam STATE_SETUP_DATA = 4'd2;
    localparam STATE_WR_LOW     = 4'd3;
    localparam STATE_WR_HIGH    = 4'd4;
    localparam STATE_POST_DELAY = 4'd5;
    localparam STATE_NEXT       = 4'd6;
    localparam STATE_DONE       = 4'd7;

    reg [3:0] state;
    reg [3:0] byte_index;
    reg [23:0] counter;
    reg [31:0] timeout;

    // Command: Screen Saver - All Dots On
    // 0x1F, 0x28, 0x61, 0x40, 0x03
    wire [7:0] cmd_data [0:4];
    assign cmd_data[0] = 8'h1F;
    assign cmd_data[1] = 8'h28;
    assign cmd_data[2] = 8'h61;
    assign cmd_data[3] = 8'h40;
    assign cmd_data[4] = 8'h03;  // p=3: All dots on

    initial begin
        state = STATE_INIT;
        byte_index = 0;
        counter = 0;
        timeout = 0;
        data_bus = 8'h00;
        wr_n = 1'b1;
        leds = 6'b000001;
    end

    always @(posedge clk) begin
        case (state)
            STATE_INIT: begin
                // Small startup delay
                counter <= counter + 1;
                if (counter >= 24'd2_700_000) begin  // 100ms
                    counter <= 0;
                    byte_index <= 0;
                    state <= STATE_WAIT_BUSY;
                    leds <= 6'b000010;
                end
            end

            STATE_WAIT_BUSY: begin
                // Wait for BUSY to go LOW (display ready)
                timeout <= timeout + 1;
                leds[5] <= busy;  // Show busy status on LED
                
                if (busy == 1'b0 || timeout >= BUSY_TIMEOUT) begin
                    timeout <= 0;
                    state <= STATE_SETUP_DATA;
                    leds <= 6'b000100;
                end
            end

            STATE_SETUP_DATA: begin
                // Put data on bus, WR still high
                data_bus <= cmd_data[byte_index];
                counter <= 0;
                state <= STATE_WR_LOW;
                leds <= 6'b001000;
            end

            STATE_WR_LOW: begin
                // Drive WR low
                wr_n <= 1'b0;
                counter <= counter + 1;
                if (counter >= WR_LOW_CYCLES) begin
                    counter <= 0;
                    state <= STATE_WR_HIGH;
                    leds <= 6'b010000;
                end
            end

            STATE_WR_HIGH: begin
                // Raise WR - data latches on rising edge
                wr_n <= 1'b1;
                counter <= 0;
                state <= STATE_POST_DELAY;
            end

            STATE_POST_DELAY: begin
                // Wait 20us after write
                counter <= counter + 1;
                if (counter >= POST_DELAY_CYCLES) begin
                    counter <= 0;
                    state <= STATE_NEXT;
                end
            end

            STATE_NEXT: begin
                if (byte_index >= 4) begin
                    // All 5 bytes sent
                    state <= STATE_DONE;
                    leds <= 6'b100000;
                end else begin
                    byte_index <= byte_index + 1;
                    state <= STATE_WAIT_BUSY;
                    leds <= 6'b000010;
                end
            end

            STATE_DONE: begin
                // Success - all LEDs on
                leds <= 6'b111111;
                wr_n <= 1'b1;
            end
        endcase
    end

endmodule
