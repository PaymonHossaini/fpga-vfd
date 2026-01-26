// VFD Latch Edge Test
// Tests whether data latches on falling or rising edge of WR
// Sequence: 0xFF on bus -> WR LOW -> 0x00 on bus -> WR HIGH
// If screen shows white (0xFF): latches on falling edge
// If screen shows black (0x00): latches on rising edge
// If mixed: latches on both

module vfd_latch_test (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    // States
    localparam STATE_INIT       = 4'd0;
    localparam STATE_HDR_FETCH  = 4'd1;
    localparam STATE_HDR_WAIT   = 4'd2;
    localparam STATE_HDR_SETUP  = 4'd3;
    localparam STATE_HDR_PULSE  = 4'd4;
    localparam STATE_HDR_HOLD   = 4'd5;
    localparam STATE_HDR_DELAY  = 4'd6;
    localparam STATE_HDR_NEXT   = 4'd7;
    // DMA test states
    localparam STATE_DMA_FF     = 4'd8;   // Put 0xFF on bus
    localparam STATE_DMA_WR_LOW = 4'd9;   // WR goes LOW (with 0xFF)
    localparam STATE_DMA_00     = 4'd10;  // Change to 0x00 (WR still LOW)
    localparam STATE_DMA_WR_HIGH= 4'd11;  // WR goes HIGH (with 0x00)
    localparam STATE_DMA_WAIT   = 4'd12;  // Wait before next
    localparam STATE_DMA_NEXT   = 4'd13;
    localparam STATE_DONE       = 4'd14;
    
    reg [3:0] state;
    reg [23:0] counter;
    reg [15:0] timer;
    reg [12:0] byte_idx;
    reg [7:0] latched_byte;
    
    // 27MHz = 37ns per cycle
    // Header timing (generous)
    localparam HDR_SETUP = 16'd270;   // 10us
    localparam HDR_PULSE = 16'd270;   // 10us
    localparam HDR_HOLD  = 16'd270;   // 10us
    localparam HDR_DELAY = 16'd2700;  // 100us
    localparam HDR_LONG  = 16'd54000; // 2ms after last header byte
    
    // DMA timing (generous for testing)
    localparam DMA_WAIT_SHORT = 16'd27;   // 1us
    localparam DMA_WAIT_LONG  = 16'd405;  // 15us
    
    localparam NUM_HEADER = 13'd8;
    localparam NUM_DATA = 13'd4096;
    
    always @(posedge clk) begin
        case (state)
            STATE_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_idx <= 13'd0;
                leds <= 6'b000001;
                timer <= 16'd0;
                // Wait 100ms for VFD init
                if (counter < 24'd2700000) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 24'd0;
                    state <= STATE_HDR_FETCH;
                end
            end
            
            // ========== HEADER (same as vfd_image_display.v) ==========
            STATE_HDR_FETCH: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                timer <= 16'd0;
                case (byte_idx)
                    13'd0: latched_byte <= 8'h02;  // STX
                    13'd1: latched_byte <= 8'h44;  // DMA header
                    13'd2: latched_byte <= 8'h00;  // DAD
                    13'd3: latched_byte <= 8'h46;  // Bit image write
                    13'd4: latched_byte <= 8'h00;  // Start addr low
                    13'd5: latched_byte <= 8'h00;  // Start addr high
                    13'd6: latched_byte <= 8'h00;  // Size low (0x1000)
                    13'd7: latched_byte <= 8'h10;  // Size high
                    default: latched_byte <= 8'h00;
                endcase
                state <= STATE_HDR_WAIT;
            end
            
            STATE_HDR_WAIT: begin
                wr_n <= 1'b1;
                leds <= {ready, 5'b00010};
                if (timer < 16'd27000) begin  // 1ms timeout
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_HDR_SETUP;
                end
            end
            
            STATE_HDR_SETUP: begin
                data_bus <= latched_byte;
                wr_n <= 1'b1;
                leds <= 6'b000100;
                if (timer < HDR_SETUP) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_HDR_PULSE;
                end
            end
            
            STATE_HDR_PULSE: begin
                data_bus <= latched_byte;
                wr_n <= 1'b0;
                leds <= 6'b001000;
                if (timer < HDR_PULSE) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_HDR_HOLD;
                end
            end
            
            STATE_HDR_HOLD: begin
                data_bus <= latched_byte;
                wr_n <= 1'b1;
                leds <= 6'b010000;
                if (timer < HDR_HOLD) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_HDR_DELAY;
                end
            end
            
            STATE_HDR_DELAY: begin
                data_bus <= 8'h00;
                wr_n <= 1'b1;
                if (byte_idx == 13'd7) begin
                    if (timer < HDR_LONG) begin
                        timer <= timer + 1;
                    end else begin
                        state <= STATE_HDR_NEXT;
                    end
                end else begin
                    if (timer < HDR_DELAY) begin
                        timer <= timer + 1;
                    end else begin
                        state <= STATE_HDR_NEXT;
                    end
                end
            end
            
            STATE_HDR_NEXT: begin
                timer <= 16'd0;
                if (byte_idx < NUM_HEADER - 1) begin
                    byte_idx <= byte_idx + 1;
                    state <= STATE_HDR_FETCH;
                end else begin
                    byte_idx <= NUM_HEADER;
                    state <= STATE_DMA_FF;
                end
            end
            
            // ========== DMA LATCH TEST ==========
            // Sequence: 00 on bus -> WR LOW -> FF on bus -> WR HIGH -> wait
            // FLIPPED from before to verify
            
            STATE_DMA_FF: begin
                // Put 0x00 on bus, WR still HIGH
                data_bus <= 8'h00;
                wr_n <= 1'b1;
                leds <= 6'b100000;
                if (timer < DMA_WAIT_SHORT) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_DMA_WR_LOW;
                end
            end
            
            STATE_DMA_WR_LOW: begin
                // WR goes LOW with 0x00 on bus
                // If data latches on falling edge, VFD sees 0x00
                data_bus <= 8'h00;
                wr_n <= 1'b0;
                if (timer < DMA_WAIT_SHORT) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_DMA_00;
                end
            end
            
            STATE_DMA_00: begin
                // Change data to 0xFF while WR is still LOW
                data_bus <= 8'hFF;
                wr_n <= 1'b0;
                if (timer < DMA_WAIT_SHORT) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_DMA_WR_HIGH;
                end
            end
            
            STATE_DMA_WR_HIGH: begin
                // WR goes HIGH with 0xFF on bus
                // If data latches on rising edge, VFD sees 0xFF
                data_bus <= 8'hFF;
                wr_n <= 1'b1;
                if (timer < DMA_WAIT_SHORT) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_DMA_WAIT;
                end
            end
            
            STATE_DMA_WAIT: begin
                // Wait 15us before next byte
                data_bus <= 8'h00;
                wr_n <= 1'b1;
                if (timer < DMA_WAIT_LONG) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_DMA_NEXT;
                end
            end
            
            STATE_DMA_NEXT: begin
                timer <= 16'd0;
                if (byte_idx < NUM_HEADER + NUM_DATA - 1) begin
                    byte_idx <= byte_idx + 1;
                    state <= STATE_DMA_FF;
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
        timer = 16'd0;
        byte_idx = 13'd0;
        wr_n = 1'b1;
        data_bus = 8'd0;
        leds = 6'd0;
        latched_byte = 8'd0;
    end

endmodule
