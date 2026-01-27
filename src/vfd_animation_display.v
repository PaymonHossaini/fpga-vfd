// VFD Animation Display - Cycles through frames from ROM
// Based on vfd_image_display_simple.v with animation loop added

module vfd_image_display (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds,
    output wire uart_tx_pin
);

    assign uart_tx_pin = 1'b1;  // Unused

    // Animation parameters
    localparam NUM_FRAMES = 4;
    localparam BYTES_PER_FRAME = 4096;
    localparam FRAME_DELAY = 24'd1572000;  // 360ms at 27MHz

    // States
    localparam S_INIT       = 4'd0;
    localparam S_HDR_SETUP  = 4'd1;
    localparam S_HDR_WR_LO  = 4'd2;
    localparam S_HDR_WR_HI  = 4'd3;
    localparam S_HDR_DELAY  = 4'd4;
    localparam S_HDR_NEXT   = 4'd5;
    localparam S_DMA_READ   = 4'd6;
    localparam S_DMA_WR_LO  = 4'd7;
    localparam S_DMA_WR_HI  = 4'd8;
    localparam S_DMA_NEXT   = 4'd9;
    localparam S_FRAME_WAIT = 4'd10;  // Wait between frames
    localparam S_NEXT_FRAME = 4'd11;  // Advance to next frame
    
    reg [3:0] state;
    reg [23:0] counter;
    reg [15:0] timer;
    reg [12:0] byte_idx;      // Byte within frame (0-4095)
    reg [1:0] frame_idx;      // Current frame (0-3)
    reg [13:0] rom_addr;      // Full ROM address (14 bits for 16KB)
    reg [7:0] latched_byte;
    
    // Header timing
    localparam HDR_TIME  = 16'd270;
    localparam HDR_DELAY = 16'd2700;
    localparam HDR_LONG  = 16'd54000;
    
    localparam NUM_HEADER = 13'd8;
    
    // Animation ROM
    wire [7:0] rom_data;
    vfd_animation_rom anim_rom (
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
                frame_idx <= 0;
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
            
            // === HEADER ===
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
                    // ROM address = frame_idx * 4096 + byte_idx
                    rom_addr <= {frame_idx, 12'd0};
                    state <= S_DMA_READ;
                end
            end
            
            // === DMA DATA ===
            S_DMA_READ: begin
                wr_n <= 1'b1;
                leds <= {1'b1, frame_idx};  // Show frame number on LEDs
                timer <= timer + 1;
                if (timer >= 16'd10) begin
                    latched_byte <= rom_data;
                    timer <= 0;
                    state <= S_DMA_WR_LO;
                end
            end
            
            S_DMA_WR_LO: begin
                wr_n <= 1'b0;
                data_bus <= latched_byte;
                state <= S_DMA_WR_HI;
            end
            
            S_DMA_WR_HI: begin
                wr_n <= 1'b1;
                state <= S_DMA_NEXT;
            end
            
            S_DMA_NEXT: begin
                if (byte_idx < BYTES_PER_FRAME - 1) begin
                    byte_idx <= byte_idx + 1;
                    rom_addr <= rom_addr + 1;
                    state <= S_DMA_READ;
                end else begin
                    // Frame complete - wait before next
                    counter <= 0;
                    state <= S_FRAME_WAIT;
                end
            end
            
            // === ANIMATION LOOP ===
            S_FRAME_WAIT: begin
                // Wait for frame duration
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                counter <= counter + 1;
                if (counter >= FRAME_DELAY) begin
                    counter <= 0;
                    state <= S_NEXT_FRAME;
                end
            end
            
            S_NEXT_FRAME: begin
                // Advance to next frame (loop)
                if (frame_idx < NUM_FRAMES - 1) begin
                    frame_idx <= frame_idx + 1;
                end else begin
                    frame_idx <= 0;  // Loop back to first frame
                end
                byte_idx <= 0;
                timer <= 0;
                // Calculate new ROM base address
                rom_addr <= {frame_idx + 1, 12'd0};  // Pre-calculate next frame address
                state <= S_HDR_SETUP;  // Re-send header for each frame
            end
            
            default: state <= S_INIT;
        endcase
    end
    
    initial begin
        state = S_INIT;
        counter = 0;
        timer = 0;
        byte_idx = 0;
        frame_idx = 0;
        rom_addr = 0;
        wr_n = 1'b1;
        data_bus = 8'h00;
        leds = 6'b0;
        latched_byte = 8'h00;
    end

endmodule
