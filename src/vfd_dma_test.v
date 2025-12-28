// VFD Graphic DMA Mode Test
// SW6 must be ON for this mode!
// Uses direct memory writes: STX 44h DAD 46h aL aH sL sH d(1)...d(s)

module vfd_dma_test (
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
    localparam SETUP_TIME  = 16'd270;     // 10us data setup time
    localparam PULSE_TIME  = 16'd270;     // 10us WR pulse width  
    localparam HOLD_TIME   = 16'd270;     // 10us data hold time (back to short)
    localparam DELAY_SHORT = 24'd27000;   // 1ms between bytes
    localparam DELAY_LONG  = 24'd270000;  // 10ms after header before data
    localparam DELAY_DATA  = 24'd2700;    // 100us between data bytes (FAST!)
    
    // MINIMAL DMA test: write just 3 bytes to verify timing
    // Protocol: STX 44h DAD 46h aL aH sL sH d(1)...d(s)
    // Command: 02 44 00 46 00 00 03 00 [3 bytes of data]
    // Total: 8 header bytes + 3 data bytes = 11 bytes
    localparam NUM_BYTES = 8'd11;
    
    reg [7:0] current_byte;
    reg [23:0] post_delay;
    
    always @(*) begin
        case (byte_idx)
            // DMA write command header
            8'd0: begin current_byte = 8'h02; post_delay = DELAY_SHORT; end  // STX
            8'd1: begin current_byte = 8'h44; post_delay = DELAY_SHORT; end  // 44h
            8'd2: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end  // DAD = 0 (display address)
            8'd3: begin current_byte = 8'h46; post_delay = DELAY_SHORT; end  // 46h (bit image write cmd)
            8'd4: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end  // aL = 0 (start addr low)
            8'd5: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end  // aH = 0 (start addr high)
            8'd6: begin current_byte = 8'h03; post_delay = DELAY_SHORT; end  // sL = 3 (size low)
            8'd7: begin current_byte = 8'h00; post_delay = DELAY_LONG; end   // sH = 0 - long delay before data
            
            // 3 bytes: distinct pattern - send FAST
            8'd8:  begin current_byte = 8'hAA; post_delay = DELAY_DATA; end  // 10101010
            8'd9:  begin current_byte = 8'h55; post_delay = DELAY_DATA; end  // 01010101
            8'd10: begin current_byte = 8'hF0; post_delay = DELAY_LONG; end  // 11110000
            
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
                data_bus <= current_byte;
                wr_n <= 1'b1;
                wr_timer <= 16'd0;
                leds <= 6'b000100;
                state <= STATE_SETUP_HOLD;
            end
            
            STATE_SETUP_HOLD: begin
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
                // Keep data stable during hold time
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
                data_bus <= 8'h00;  // Clear bus AFTER hold complete
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
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                leds[4:0] <= 5'b00000;
                leds[5] <= counter[23];
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
