// VFD Pattern Test - Exact copy of vfd_image_display.v but with constant 0x0F pattern
// Tests bit order: 0x0F = 00001111 should show 4 pixels on, 4 pixels off per byte

module vfd_image_display (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    localparam STATE_INIT       = 4'd0;
    localparam STATE_HDR_FETCH  = 4'd1;
    localparam STATE_HDR_WAIT   = 4'd2;
    localparam STATE_HDR_SETUP  = 4'd3;
    localparam STATE_HDR_PULSE  = 4'd4;
    localparam STATE_HDR_HOLD   = 4'd5;
    localparam STATE_HDR_DELAY  = 4'd6;
    localparam STATE_HDR_NEXT   = 4'd7;
    localparam STATE_DMA_FETCH      = 4'd8;
    localparam STATE_DMA_SETUP      = 4'd9;
    localparam STATE_DMA_PULSE      = 4'd10;
    localparam STATE_DMA_WAIT_LOW   = 4'd11;
    localparam STATE_DMA_WAIT_HIGH  = 4'd12;
    localparam STATE_DMA_NEXT       = 4'd13;
    localparam STATE_DONE           = 4'd14;
    
    reg [3:0] state;
    reg [23:0] counter;
    reg [15:0] timer;
    reg [12:0] byte_idx;
    
    // 27MHz = 37ns per cycle
    localparam DMA_SETUP = 16'd2;      // ~74ns (min 50ns)
    localparam DMA_PULSE = 16'd3;      // ~111ns (min 100ns)
    localparam DMA_HOLD  = 16'd1;      // ~37ns (min 10ns)
    localparam DMA_WAIT  = 16'd405;    // ~15us
    
    // Header timing
    localparam HDR_SETUP = 16'd270;
    localparam HDR_PULSE = 16'd270;
    localparam HDR_HOLD  = 16'd270;
    localparam HDR_DELAY = 16'd2700;
    localparam HDR_LONG  = 16'd54000;
    
    localparam NUM_HEADER = 13'd8;
    localparam NUM_DATA = 13'd4096;
    
    // Test pattern: constant 0x0F instead of ROM
    localparam TEST_PATTERN = 8'h0F;  // 00001111
    
    reg [7:0] latched_byte;
    
    always @(posedge clk) begin
        case (state)
            STATE_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_idx <= 13'd0;
                leds <= 6'b000001;
                timer <= 16'd0;
                if (counter < 24'd2700000) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 24'd0;
                    state <= STATE_HDR_FETCH;
                end
            end
            
            // ========== HEADER ==========
            STATE_HDR_FETCH: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                timer <= 16'd0;
                case (byte_idx)
                    13'd0: latched_byte <= 8'h02;
                    13'd1: latched_byte <= 8'h44;
                    13'd2: latched_byte <= 8'h00;
                    13'd3: latched_byte <= 8'h46;
                    13'd4: latched_byte <= 8'h00;
                    13'd5: latched_byte <= 8'h00;
                    13'd6: latched_byte <= 8'h00;
                    13'd7: latched_byte <= 8'h10;
                    default: latched_byte <= 8'h00;
                endcase
                state <= STATE_HDR_WAIT;
            end
            
            STATE_HDR_WAIT: begin
                wr_n <= 1'b1;
                leds <= {ready, 5'b00010};
                if (timer < 16'd27000) begin
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
                    state <= STATE_DMA_FETCH;
                end
            end
            
            // ========== DMA DATA ==========
            STATE_DMA_FETCH: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                timer <= 16'd0;
                latched_byte <= TEST_PATTERN;  // Use constant pattern instead of ROM
                leds <= 6'b100000;
                state <= STATE_DMA_SETUP;
            end
            
            STATE_DMA_SETUP: begin
                data_bus <= latched_byte;
                wr_n <= 1'b1;
                if (timer < DMA_SETUP) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_DMA_PULSE;
                end
            end
            
            STATE_DMA_PULSE: begin
                data_bus <= latched_byte;
                wr_n <= 1'b0;
                if (timer < DMA_PULSE) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    wr_n <= 1'b1;
                    state <= STATE_DMA_WAIT_LOW;
                end
            end
            
            STATE_DMA_WAIT_LOW: begin
                data_bus <= latched_byte;
                wr_n <= 1'b1;
                if (ready == 1'b0) begin
                    state <= STATE_DMA_WAIT_HIGH;
                end
            end
            
            STATE_DMA_WAIT_HIGH: begin
                data_bus <= latched_byte;
                wr_n <= 1'b1;
                if (ready == 1'b1) begin
                    state <= STATE_DMA_NEXT;
                end
            end
            
            STATE_DMA_NEXT: begin
                timer <= 16'd0;
                if (byte_idx < NUM_HEADER + NUM_DATA - 1) begin
                    byte_idx <= byte_idx + 1;
                    state <= STATE_DMA_FETCH;
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
