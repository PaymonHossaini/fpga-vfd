// VFD Graphics Test v47 - Ignore ready signal, use only timing
// Test if ready signal is the issue

module vfd_graphics_v47 (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    // Conservative timing - no ready check
    localparam SETUP_TIME = 270;      // 10µs data setup
    localparam WR_PULSE_WIDTH = 540;  // 20µs WR low time
    localparam HOLD_TIME = 270;       // 10µs data hold
    localparam BYTE_DELAY = 270000;   // 10ms between bytes
    localparam INIT_DELAY = 810000;   // 30ms after init

    // State machine
    localparam STATE_INIT = 0;
    localparam STATE_SETUP = 1;
    localparam STATE_SETUP_HOLD = 2;
    localparam STATE_PULSE_WR = 3;
    localparam STATE_HOLD = 4;
    localparam STATE_POST_DELAY = 5;
    localparam STATE_NEXT = 6;
    localparam STATE_DONE = 7;

    reg [3:0] state;
    reg [19:0] delay_counter;
    reg [7:0] byte_index;
    
    // 3 dots at x=50, x=128, x=200, all at y=64
    localparam NUM_BYTES = 38;
    reg [7:0] cmd_sequence [0:NUM_BYTES-1];
    
    initial begin
        // Initialize display (US ( * 1 1 1 1)
        cmd_sequence[0] = 8'h1F;
        cmd_sequence[1] = 8'h28;
        cmd_sequence[2] = 8'h2A;
        cmd_sequence[3] = 8'h01;
        cmd_sequence[4] = 8'h01;
        cmd_sequence[5] = 8'h01;
        cmd_sequence[6] = 8'h01;
        
        // Clear screen (CLR = 0x0C)
        cmd_sequence[7] = 8'h0C;
        
        // Set cursor to 0,0 (US $ xL xH yL yH)
        cmd_sequence[8] = 8'h1F;
        cmd_sequence[9] = 8'h24;
        cmd_sequence[10] = 8'h00;
        cmd_sequence[11] = 8'h00;
        cmd_sequence[12] = 8'h00;
        cmd_sequence[13] = 8'h00;
        
        // === DOT 1: x=50, y=64 ===
        cmd_sequence[14] = 8'h1F;
        cmd_sequence[15] = 8'h28;
        cmd_sequence[16] = 8'h64;
        cmd_sequence[17] = 8'h10;
        cmd_sequence[18] = 8'h32;  // x low = 50
        cmd_sequence[19] = 8'h00;  // x high
        cmd_sequence[20] = 8'h40;  // y low = 64
        cmd_sequence[21] = 8'h00;  // y high
        
        // === DOT 2: x=128, y=64 ===
        cmd_sequence[22] = 8'h1F;
        cmd_sequence[23] = 8'h28;
        cmd_sequence[24] = 8'h64;
        cmd_sequence[25] = 8'h10;
        cmd_sequence[26] = 8'h80;  // x low = 128
        cmd_sequence[27] = 8'h00;  // x high
        cmd_sequence[28] = 8'h40;  // y low = 64
        cmd_sequence[29] = 8'h00;  // y high
        
        // === DOT 3: x=200, y=64 ===
        cmd_sequence[30] = 8'h1F;
        cmd_sequence[31] = 8'h28;
        cmd_sequence[32] = 8'h64;
        cmd_sequence[33] = 8'h10;
        cmd_sequence[34] = 8'hC8;  // x low = 200
        cmd_sequence[35] = 8'h00;  // x high
        cmd_sequence[36] = 8'h40;  // y low = 64
        cmd_sequence[37] = 8'h00;  // y high
    end

    always @(posedge clk) begin
        // Show state and ready on LEDs
        leds[3:0] <= state[3:0];
        leds[4] <= ready;
        leds[5] <= (state == STATE_DONE);
        
        case (state)
            STATE_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_index <= 0;
                delay_counter <= INIT_DELAY;
                state <= STATE_SETUP;
            end
            
            STATE_SETUP: begin
                // Wait for initial delay, then put data on bus
                if (delay_counter > 0) begin
                    delay_counter <= delay_counter - 1;
                end else begin
                    data_bus <= cmd_sequence[byte_index];
                    wr_n <= 1'b1;
                    delay_counter <= SETUP_TIME;
                    state <= STATE_SETUP_HOLD;
                end
            end
            
            STATE_SETUP_HOLD: begin
                if (delay_counter > 0) begin
                    delay_counter <= delay_counter - 1;
                end else begin
                    state <= STATE_PULSE_WR;
                    delay_counter <= WR_PULSE_WIDTH;
                end
            end
            
            STATE_PULSE_WR: begin
                wr_n <= 1'b0;
                if (delay_counter > 0) begin
                    delay_counter <= delay_counter - 1;
                end else begin
                    state <= STATE_HOLD;
                    delay_counter <= HOLD_TIME;
                end
            end
            
            STATE_HOLD: begin
                wr_n <= 1'b1;
                if (delay_counter > 0) begin
                    delay_counter <= delay_counter - 1;
                end else begin
                    state <= STATE_POST_DELAY;
                    // Extra long delay after init/clear/cursor commands
                    if (byte_index == 6 || byte_index == 7 || byte_index == 13) begin
                        delay_counter <= INIT_DELAY;
                    end else begin
                        delay_counter <= BYTE_DELAY;
                    end
                end
            end
            
            STATE_POST_DELAY: begin
                if (delay_counter > 0) begin
                    delay_counter <= delay_counter - 1;
                end else begin
                    state <= STATE_NEXT;
                end
            end
            
            STATE_NEXT: begin
                if (byte_index < NUM_BYTES - 1) begin
                    byte_index <= byte_index + 1;
                    state <= STATE_SETUP;
                    delay_counter <= BYTE_DELAY;  // Inter-byte delay
                end else begin
                    state <= STATE_DONE;
                end
            end
            
            STATE_DONE: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
            end
            
            default: state <= STATE_INIT;
        endcase
    end

endmodule
