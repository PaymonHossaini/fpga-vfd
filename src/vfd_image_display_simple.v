// VFD Image Display - Simplified Version
// Uses vfd_image_display module name so build.sh works unchanged
// KEY: Data must only change while WR is LOW (not while HIGH)
// All DMA timing delays can be 0 - the state transitions provide enough time

module vfd_image_display (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds,
    output wire uart_tx_pin  // Unused - for interface compatibility
);

    // Tie off unused UART
    assign uart_tx_pin = 1'b1;

    // States
    localparam S_INIT       = 4'd0;
    localparam S_HDR_SETUP  = 4'd1;
    localparam S_HDR_WR_LO  = 4'd2;
    localparam S_HDR_WR_HI  = 4'd3;
    localparam S_HDR_DELAY  = 4'd4;
    localparam S_HDR_NEXT   = 4'd5;
    localparam S_DMA_READ   = 4'd6;   // Wait for ROM data
    localparam S_DMA_WR_LO  = 4'd7;   // WR low, change data
    localparam S_DMA_WR_HI  = 4'd8;   // WR high (latch)
    localparam S_DMA_NEXT   = 4'd9;
    localparam S_DONE       = 4'd10;
    
    reg [3:0] state;
    reg [23:0] counter;
    reg [15:0] timer;
    reg [12:0] byte_idx;
    reg [12:0] rom_addr;
    reg [7:0] latched_byte;
    
    // 27MHz = 37ns per cycle
    // No DMA wait needed - state transitions provide enough time
    
    // Header timing (more relaxed for command mode)
    localparam HDR_TIME  = 16'd270;   // ~10us
    localparam HDR_DELAY = 16'd2700;  // ~100us
    localparam HDR_LONG  = 16'd54000; // ~2ms after last header byte
    
    localparam NUM_HEADER = 13'd8;
    localparam NUM_DATA = 13'd4096;
    
    // ROM
    wire [7:0] rom_data;
    vfd_image_rom image_rom (
        .clk(clk),
        .addr(rom_addr),
        .data(rom_data)
    );
    
    // Header bytes: 02 44 00 46 00 00 00 10
    wire [7:0] header_byte;
    assign header_byte = (byte_idx == 0) ? 8'h02 :
                         (byte_idx == 1) ? 8'h44 :
                         (byte_idx == 2) ? 8'h00 :
                         (byte_idx == 3) ? 8'h46 :
                         (byte_idx == 4) ? 8'h00 :
                         (byte_idx == 5) ? 8'h00 :
                         (byte_idx == 6) ? 8'h00 :
                         (byte_idx == 7) ? 8'h10 : 8'h00;
    
    always @(posedge clk) begin
        case (state)
            S_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_idx <= 0;
                rom_addr <= 0;
                timer <= 0;
                leds <= 6'b000001;
                // Wait 100ms at startup
                if (counter < 24'd2700000) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 0;
                    state <= S_HDR_SETUP;
                end
            end
            
            // === HEADER (command mode - data changes while WR high is OK) ===
            S_HDR_SETUP: begin
                data_bus <= header_byte;
                wr_n <= 1'b1;
                timer <= timer + 1;
                if (timer >= HDR_TIME) begin
                    timer <= 0;
                    state <= S_HDR_WR_LO;
                end
            end
            
            S_HDR_WR_LO: begin
                wr_n <= 1'b0;
                timer <= timer + 1;
                if (timer >= HDR_TIME) begin
                    timer <= 0;
                    state <= S_HDR_WR_HI;
                end
            end
            
            S_HDR_WR_HI: begin
                wr_n <= 1'b1;
                timer <= timer + 1;
                if (timer >= HDR_TIME) begin
                    timer <= 0;
                    state <= S_HDR_DELAY;
                end
            end
            
            S_HDR_DELAY: begin
                data_bus <= 8'h00;
                timer <= timer + 1;
                if (byte_idx == 7) begin
                    // Longer delay after last header byte
                    if (timer >= HDR_LONG) begin
                        timer <= 0;
                        state <= S_HDR_NEXT;
                    end
                end else begin
                    if (timer >= HDR_DELAY) begin
                        timer <= 0;
                        state <= S_HDR_NEXT;
                    end
                end
            end
            
            S_HDR_NEXT: begin
                if (byte_idx < NUM_HEADER - 1) begin
                    byte_idx <= byte_idx + 1;
                    state <= S_HDR_SETUP;
                end else begin
                    byte_idx <= 0;
                    rom_addr <= 0;
                    state <= S_DMA_READ;
                end
            end
            
            // === DMA DATA (data must change while WR is LOW) ===
            S_DMA_READ: begin
                // Wait for ROM data
                wr_n <= 1'b1;
                leds <= 6'b100000;
                timer <= timer + 1;
                if (timer >= 16'd10) begin  // 10 cycles for ROM
                    latched_byte <= rom_data;
                    timer <= 0;
                    state <= S_DMA_WR_LO;
                end
            end
            
            S_DMA_WR_LO: begin
                // WR goes low, THEN change data
                wr_n <= 1'b0;
                data_bus <= latched_byte;
                state <= S_DMA_WR_HI;
            end
            
            S_DMA_WR_HI: begin
                // WR goes high - rising edge latches data
                wr_n <= 1'b1;
                state <= S_DMA_NEXT;
            end
            
            S_DMA_NEXT: begin
                if (rom_addr < NUM_DATA - 1) begin
                    rom_addr <= rom_addr + 1;
                    state <= S_DMA_READ;
                end else begin
                    state <= S_DONE;
                end
            end
            
            S_DONE: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                leds <= 6'b111111;
            end
            
            default: state <= S_INIT;
        endcase
    end
    
    initial begin
        state = S_INIT;
        counter = 0;
        timer = 0;
        byte_idx = 0;
        rom_addr = 0;
        wr_n = 1'b1;
        data_bus = 8'h00;
        leds = 6'b0;
        latched_byte = 8'h00;
    end

endmodule
