// VFD Image Display via DMA Mode
// DMA timing from 8.1.2:
//   Data setup: 50ns min before /WR falls
//   /WR pulse: 100ns min (low)
//   Data hold: 10ns min after /WR rises  
//   15us min between /WR rising and next /WR falling

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
    localparam STATE_DMA_WAIT_LOW   = 4'd11;  // wait for READY to go LOW
    localparam STATE_DMA_WAIT_HIGH  = 4'd12;  // wait for READY to go HIGH
    localparam STATE_DMA_NEXT       = 4'd13;
    localparam STATE_DONE           = 4'd14;
    
    reg [3:0] state;
    reg [23:0] counter;
    reg [15:0] timer;
    reg [12:0] byte_idx;
    
    // 27MHz = 37ns per cycle
    // DMA timing:
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
    
    wire [12:0] rom_addr = (byte_idx >= NUM_HEADER) ? (byte_idx - NUM_HEADER) : 13'd0;
    wire [7:0] rom_data;
    
    vfd_image_rom image_rom (
        .addr(rom_addr),
        .data(rom_data)
    );
    
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
                leds <= 6'b000010;
                if (ready == 1'b1) begin
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
            // Sequence: FETCH -> SETUP -> PULSE -> HOLD -> WAIT -> NEXT
            
            STATE_DMA_FETCH: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                timer <= 16'd0;
                latched_byte <= rom_data;
                leds <= 6'b100000;
                state <= STATE_DMA_SETUP;
            end
            
            STATE_DMA_SETUP: begin
                // Data valid, WR high - setup time before WR falls
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
                // Data valid, WR low - the actual write pulse
                data_bus <= latched_byte;
                wr_n <= 1'b0;
                if (timer < DMA_PULSE) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    wr_n <= 1'b1;  // Release WR
                    state <= STATE_DMA_WAIT_LOW;
                end
            end
            
            STATE_DMA_WAIT_LOW: begin
                // Wait for READY to go LOW (VFD acknowledges byte received)
                data_bus <= latched_byte;
                wr_n <= 1'b1;
                if (ready == 1'b0) begin
                    // READY went low, VFD is processing
                    state <= STATE_DMA_WAIT_HIGH;
                end
                // Stay here until READY goes low
            end
            
            STATE_DMA_WAIT_HIGH: begin
                // Wait for READY to go HIGH (VFD ready for next byte)
                data_bus <= latched_byte;
                wr_n <= 1'b1;
                if (ready == 1'b1) begin
                    // READY is high, safe to send next byte
                    state <= STATE_DMA_NEXT;
                end
                // Stay here until READY goes high
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