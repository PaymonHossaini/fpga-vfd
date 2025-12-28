// VFD Single Byte Test - Debug WR timing with image command
// Send minimal image command to diagnose timing issues

module vfd_single_byte_test (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    localparam STATE_INIT       = 4'd0;
    localparam STATE_WAIT_RDY   = 4'd1;
    localparam STATE_SETUP      = 4'd2;
    localparam STATE_SETUP_HOLD = 4'd3;
    localparam STATE_PULSE_WR   = 4'd4;
    localparam STATE_HOLD       = 4'd5;
    localparam STATE_POST_DELAY = 4'd6;
    localparam STATE_NEXT       = 4'd7;
    localparam STATE_DONE       = 4'd8;
    
    reg [3:0] state;
    reg [23:0] counter;
    reg [23:0] delay_counter;
    reg [15:0] wr_timer;
    reg [7:0] byte_idx;
    
    // At 27MHz: 27 cycles = 1µs
    // CONSERVATIVE timing - 1 byte worked with these
    localparam SETUP_TIME  = 16'd270;    // 10us data setup time
    localparam PULSE_TIME  = 16'd270;    // 10us WR pulse width  
    localparam HOLD_TIME   = 16'd270;    // 10us data hold time
    localparam DELAY_SHORT = 24'd270000; // 10ms between bytes
    localparam DELAY_LONG  = 24'd810000; // 30ms after init/clear
    
    // Command sequence for 3x8 pixel image at (50,50):
    // ESC @ (init) + Clear + 1F 28 64 21 + position + size + g + 3 data bytes
    // Total: 2 + 1 + 4 + 4 + 4 + 1 + 3 = 19 bytes
    localparam NUM_BYTES = 8'd19;
    
    reg [7:0] current_byte;
    reg [23:0] post_delay;
    
    always @(*) begin
        case (byte_idx)
            // Initialize display: ESC @
            8'd0: begin current_byte = 8'h1B; post_delay = DELAY_SHORT; end
            8'd1: begin current_byte = 8'h40; post_delay = DELAY_LONG; end
            
            // Clear screen
            8'd2: begin current_byte = 8'h0C; post_delay = DELAY_LONG; end
            
            // Draw 3x8 image at position (50, 50)
            // Command: 1F 28 64 21 xPL xPH yPL yPH xL xH yL yH g data
            8'd3:  begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd4:  begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd5:  begin current_byte = 8'h64; post_delay = DELAY_SHORT; end  // 'd'
            8'd6:  begin current_byte = 8'h21; post_delay = DELAY_SHORT; end
            8'd7:  begin current_byte = 8'h32; post_delay = DELAY_SHORT; end  // xPL = 50
            8'd8:  begin current_byte = 8'h00; post_delay = DELAY_SHORT; end  // xPH = 0
            8'd9:  begin current_byte = 8'h32; post_delay = DELAY_SHORT; end  // yPL = 50
            8'd10: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end  // yPH = 0
            8'd11: begin current_byte = 8'h03; post_delay = DELAY_SHORT; end  // xL = 3 (width = 3 pixels)
            8'd12: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end  // xH = 0
            8'd13: begin current_byte = 8'h08; post_delay = DELAY_SHORT; end  // yL = 8 (height = 8 pixels)
            8'd14: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end  // yH = 0
            8'd15: begin current_byte = 8'h01; post_delay = DELAY_LONG; end   // g = 1
            
            // THREE data bytes: alternating pattern
            8'd16: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end  // col0: all on
            8'd17: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end  // col1: all off
            8'd18: begin current_byte = 8'hFF; post_delay = DELAY_LONG; end   // col2: all on
            
            default: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
        endcase
    end
    
    always @(posedge clk) begin
        case (state)
            STATE_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_idx <= 8'd0;
                leds <= 6'b000001;
                delay_counter <= 24'd0;
                // 100ms startup delay
                if (counter < 24'd2700000) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 24'd0;
                    state <= STATE_WAIT_RDY;
                end
            end
            
            STATE_WAIT_RDY: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                leds <= 6'b000010;
                if (ready == 1'b1) begin
                    state <= STATE_SETUP;
                end
            end
            
            STATE_SETUP: begin
                // Put data on bus, WR stays high
                data_bus <= current_byte;
                wr_n <= 1'b1;
                wr_timer <= 16'd0;
                leds <= 6'b000100;
                state <= STATE_SETUP_HOLD;
            end
            
            STATE_SETUP_HOLD: begin
                // Hold data stable with WR high
                data_bus <= current_byte;
                wr_n <= 1'b1;
                leds <= 6'b000100;
                if (wr_timer < SETUP_TIME) begin
                    wr_timer <= wr_timer + 1;
                end else begin
                    wr_timer <= 16'd0;
                    state <= STATE_PULSE_WR;
                end
            end
            
            STATE_PULSE_WR: begin
                // WR goes low - VFD latches data
                data_bus <= current_byte;
                wr_n <= 1'b0;
                leds <= 6'b001000;
                if (wr_timer < PULSE_TIME) begin
                    wr_timer <= wr_timer + 1;
                end else begin
                    wr_timer <= 16'd0;
                    state <= STATE_HOLD;
                end
            end
            
            STATE_HOLD: begin
                // WR goes high, keep data stable
                data_bus <= current_byte;
                wr_n <= 1'b1;
                leds <= 6'b010000;
                if (wr_timer < HOLD_TIME) begin
                    wr_timer <= wr_timer + 1;
                end else begin
                    delay_counter <= 24'd0;
                    state <= STATE_POST_DELAY;
                end
            end
            
            STATE_POST_DELAY: begin
                data_bus <= current_byte;
                wr_n <= 1'b1;
                if (delay_counter < post_delay) begin
                    delay_counter <= delay_counter + 1;
                end else if (ready == 1'b1) begin
                    state <= STATE_NEXT;
                end
            end
            
            STATE_NEXT: begin
                if (byte_idx < NUM_BYTES - 1) begin
                    byte_idx <= byte_idx + 1;
                    state <= STATE_WAIT_RDY;
                end else begin
                    state <= STATE_DONE;
                end
            end
            
            STATE_DONE: begin
                // DONE - WR stays HIGH, data goes to 0
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                leds[4:0] <= 5'b00000;
                leds[5] <= counter[23];  // Slow blink to indicate done
                counter <= counter + 1;
            end
            
            default: begin
                state <= STATE_INIT;
                wr_n <= 1'b1;
                data_bus <= 8'h00;
            end
        endcase
    end
    
    initial begin
        state = STATE_INIT;
        counter = 24'd0;
        delay_counter = 24'd0;
        wr_timer = 16'd0;
        byte_idx = 8'd0;
        wr_n = 1'b1;
        data_bus = 8'd0;
        leds = 6'd0;
    end
endmodule
