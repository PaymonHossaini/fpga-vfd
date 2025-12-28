// VFD Real-time Bit Image Test v2 - Improved Timing
// Based on vfd_drawimage_test.v with:
// 1. Longer delay after g=1 command before image data
// 2. Longer inter-byte delay for image data
// 3. Strict READY checking (no timeout fallback)
//
// Uses US ( d 21h command: 1F 28 64 21 (Dot unit real-time bit image display)
// Format: 1F 28 64 21 xPL xPH yPL yPH xL xH yL yH g d(1)...d(k)

module vfd_drawimage_test_v2 (
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
    reg [15:0] wr_timer;  // Wider for longer times
    reg [7:0] byte_idx;
    
    // IMPROVED TIMING PARAMETERS
    // At 27MHz: 27 cycles = 1µs, 27000 cycles = 1ms
    localparam DELAY_SHORT      = 24'd54000;     // 2ms between command bytes
    localparam DELAY_LONG       = 24'd810000;    // 30ms after init/clear
    localparam DELAY_PRE_IMAGE  = 24'd270000;    // 10ms after g=1 before image data
    localparam DELAY_IMAGE_BYTE = 24'd135000;    // 5ms between image data bytes
    
    // More conservative signal timing
    localparam SETUP_TIME  = 16'd54;    // 2us data setup time
    localparam PULSE_TIME  = 16'd108;   // 4us WR pulse width
    localparam HOLD_TIME   = 16'd54;    // 2us data hold time
    
    // Command sequence:
    // 64 nulls + ESC @ (2) + Clear (1) + drawImage command (13) + image data (32) = 112 bytes
    localparam NUM_BYTES = 8'd112;
    localparam NUM_NULLS = 8'd64;
    
    // Byte indices for special handling
    localparam IDX_G_BYTE = 8'd15;      // g=1 byte (after nulls offset)
    localparam IDX_FIRST_IMAGE = 8'd16; // First image data byte
    localparam IDX_LAST_IMAGE = 8'd47;  // Last image data byte
    
    reg [7:0] current_byte;
    reg [23:0] post_delay;
    
    always @(*) begin
        if (byte_idx < NUM_NULLS) begin
            current_byte = 8'h00;
            post_delay = DELAY_SHORT;
        end else begin
            case (byte_idx - NUM_NULLS)
                // Initialize display: ESC @
                8'd0: begin current_byte = 8'h1B; post_delay = DELAY_SHORT; end
                8'd1: begin current_byte = 8'h40; post_delay = DELAY_LONG; end
                
                // Clear screen
                8'd2: begin current_byte = 8'h0C; post_delay = DELAY_LONG; end
                
                // DEBUG: Send test bytes to check which bits work
                // These will display as characters on screen
                8'd3: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end  // bit 0
                8'd4: begin current_byte = 8'h02; post_delay = DELAY_SHORT; end  // bit 1
                8'd5: begin current_byte = 8'h04; post_delay = DELAY_SHORT; end  // bit 2
                8'd6: begin current_byte = 8'h08; post_delay = DELAY_SHORT; end  // bit 3
                8'd7: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end  // bit 4
                8'd8: begin current_byte = 8'h20; post_delay = DELAY_SHORT; end  // bit 5
                8'd9: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end  // bit 6
                8'd10: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end // bit 7 - THIS ONE MAY FAIL
                8'd11: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end // all bits
                8'd12: begin current_byte = 8'h55; post_delay = DELAY_SHORT; end // alternating 01010101
                8'd13: begin current_byte = 8'hAA; post_delay = DELAY_LONG; end  // alternating 10101010
                
                default: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            endcase
        end
    end
                
                // Image data: 16x16 = 16 * ceil(16/8) = 32 bytes
                // Data format per spec: column-major, 8 pixels per byte
                // For 16-pixel height: 2 bytes per column (top 8 + bottom 8)
                // Byte order: d1=col0_top, d2=col0_bot, d3=col1_top, d4=col1_bot, ...
                //
                // Drawing a VERTICAL STRIPES pattern for easy visual debugging:
                // Even columns: 0xFF (all on), Odd columns: 0x00 (all off)
                
                8'd16: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col0 top
                8'd17: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col0 bot
                8'd18: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col1 top
                8'd19: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col1 bot
                8'd20: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col2 top
                8'd21: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col2 bot
                8'd22: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col3 top
                8'd23: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col3 bot
                8'd24: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col4 top
                8'd25: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col4 bot
                8'd26: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col5 top
                8'd27: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col5 bot
                8'd28: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col6 top
                8'd29: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col6 bot
                8'd30: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col7 top
                8'd31: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col7 bot
                8'd32: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col8 top
                8'd33: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col8 bot
                8'd34: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col9 top
                8'd35: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col9 bot
                8'd36: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col10 top
                8'd37: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col10 bot
                8'd38: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col11 top
                8'd39: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col11 bot
                8'd40: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col12 top
                8'd41: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col12 bot
                8'd42: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col13 top
                8'd43: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col13 bot
                8'd44: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col14 top
                8'd45: begin current_byte = 8'hFF; post_delay = DELAY_IMAGE_BYTE; end  // col14 bot
                8'd46: begin current_byte = 8'h00; post_delay = DELAY_IMAGE_BYTE; end  // col15 top
                8'd47: begin current_byte = 8'h00; post_delay = DELAY_LONG; end        // col15 bot - final
                
                default: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            endcase
        end
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
                if (counter < 24'd2700000) counter <= counter + 1;
                else begin counter <= 24'd0; state <= STATE_WAIT_RDY; end
            end
            
            STATE_WAIT_RDY: begin
                // STRICT READY CHECK - NO TIMEOUT FALLBACK
                // Per RS-232 timing diagram: only proceed when READY is HIGH
                wr_n <= 1'b1;
                leds <= 6'b000010;
                if (ready == 1'b1) begin
                    delay_counter <= 24'd0;
                    state <= STATE_SETUP;
                end
                // No timeout - wait forever for READY
                // This ensures we never overflow the 256-byte receive buffer
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
                // Wait for data setup time before WR goes low
                wr_n <= 1'b1;
                if (wr_timer < SETUP_TIME) begin
                    wr_timer <= wr_timer + 1;
                end else begin
                    wr_timer <= 16'd0;
                    state <= STATE_PULSE_WR;
                end
            end
            
            STATE_PULSE_WR: begin
                // WR goes low, data is latched by VFD on falling edge
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
                // WR goes high, hold data stable
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
                // Wait for post-byte delay, then check READY before next byte
                if (delay_counter < post_delay) begin
                    delay_counter <= delay_counter + 1;
                end else if (ready == 1'b1) begin
                    // Only proceed when READY is high after delay
                    state <= STATE_NEXT;
                end
                // If READY is low after delay, keep waiting (buffer flow control)
            end
            
            STATE_NEXT: begin
                // DEBUG: Stop after second image byte to verify output
                // Image bytes start at byte_idx 80 (64 nulls + 16 cmd bytes)
                // Second image byte is at byte_idx 81
                if (byte_idx < 81) begin
                    byte_idx <= byte_idx + 1;
                    state <= STATE_WAIT_RDY;
                end else begin
                    state <= STATE_DONE;
                end
            end
            
            STATE_DONE: begin
                wr_n <= 1'b1;
                leds[4:0] <= 5'b00000;
                leds[5] <= counter[23];  // Slow blink to indicate done
                counter <= counter + 1;
            end
            
            default: state <= STATE_INIT;
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
