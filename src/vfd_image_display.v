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
    localparam STATE_DMA_ROM_WAIT   = 4'd9;   // wait for ROM to settle
    localparam STATE_DMA_READY      = 4'd10;  // wait for READY before starting byte
    localparam STATE_DMA_WR_LOW     = 4'd11;  // set WR low
    localparam STATE_DMA_DATA       = 4'd12;  // put data on bus
    localparam STATE_DMA_WR_HIGH    = 4'd13;  // set WR high (latch)
    localparam STATE_DMA_WAIT       = 4'd14;  // wait for READY
    localparam STATE_DMA_NEXT       = 4'd15;
    localparam STATE_DONE           = 5'd16;
    
    reg [4:0] state;  // Need 5 bits for 17 states
    reg [23:0] counter;
    reg [15:0] timer;
    reg [12:0] byte_idx;
    
    // 27MHz = 37ns per cycle
    localparam DMA_SETUP = 16'd50;     // ~1.85us (was 370ns, min 50ns)
    localparam DMA_PULSE = 16'd50;     // ~1.85us (was 555ns, min 100ns)
    localparam DMA_HOLD  = 16'd20;     // ~370ns (was 37ns, min 10ns)
    localparam DMA_WAIT  = 16'd810; 
    
    // Header timing
    localparam HDR_SETUP = 16'd270;
    localparam HDR_PULSE = 16'd270;
    localparam HDR_HOLD  = 16'd270;
    localparam HDR_DELAY = 16'd2700;
    localparam HDR_LONG  = 16'd54000;
    
    localparam NUM_HEADER = 13'd8;
    localparam NUM_DATA = 13'd4096;  // Full display size
    
    wire [12:0] rom_addr = (byte_idx >= NUM_HEADER) ? (byte_idx - NUM_HEADER) : 13'd0;
    wire [7:0] rom_data;
    
    vfd_image_rom image_rom (
        .clk(clk),
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
                leds <= {ready, 5'b00001};  // LED5 shows ready signal even during init
                timer <= 16'd0;
                if (counter < 24'd27000000) begin  // 1 second startup delay
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
                data_bus <= 8'h00;
                leds <= {ready, 5'b00010};  // LED5 shows ready signal state
                // Bypass ready check - just wait fixed time
                if (timer < 16'd27000) begin  // 1ms wait instead of ready
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_HDR_SETUP;
                end
            end
            
            STATE_HDR_SETUP: begin
                // Step 1: Set WR LOW first (before data)
                data_bus <= 8'h00;
                wr_n <= 1'b0;
                leds <= 6'b000100;
                if (timer < HDR_SETUP) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_HDR_PULSE;
                end
            end
            
            STATE_HDR_PULSE: begin
                // Step 2: Now set data while WR is LOW
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
                // Step 3: Set WR HIGH (latch on rising edge), keep data
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
            // Sequence: FETCH -> READY -> SETUP -> PULSE -> WAIT_LOW -> WAIT_HIGH -> NEXT
            
            STATE_DMA_FETCH: begin
                // Address is updated via rom_addr wire, wait for ROM to settle
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                timer <= 16'd0;
                leds <= 6'b100000;
                state <= STATE_DMA_ROM_WAIT;
            end
            
            STATE_DMA_ROM_WAIT: begin
                // Give ROM time to settle on new address
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                if (timer < 16'd50) begin  // Wait ~1.85us for ROM to settle (was 185ns)
                    timer <= timer + 1;
                end else begin
                    latched_byte <= rom_data;  // Now latch the stable data
                    timer <= 16'd0;
                    state <= STATE_DMA_READY;
                end
            end
            
            STATE_DMA_READY: begin
                // Skip READY check, just use fixed timing
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                timer <= 16'd0;
                state <= STATE_DMA_WR_LOW;
            end
            
            STATE_DMA_WR_LOW: begin
                // Step 1: Set WR LOW first (before data)
                wr_n <= 1'b0;
                data_bus <= 8'h00;
                if (timer < DMA_SETUP) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_DMA_DATA;
                end
            end
            
            STATE_DMA_DATA: begin
                // Step 2: Now set data while WR is LOW
                wr_n <= 1'b0;
                data_bus <= latched_byte;
                if (timer < DMA_PULSE) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_DMA_WR_HIGH;
                end
            end
            
            STATE_DMA_WR_HIGH: begin
                // Step 3: Set WR HIGH (latch on rising edge), keep data
                wr_n <= 1'b1;
                data_bus <= latched_byte;
                if (timer < DMA_HOLD) begin
                    timer <= timer + 1;
                end else begin
                    timer <= 16'd0;
                    state <= STATE_DMA_WAIT;
                end
            end
            
            STATE_DMA_WAIT: begin
                // Step 4: Hold time done, wait before next byte
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                if (timer < DMA_WAIT) begin
                    timer <= timer + 1;
                end else begin
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
