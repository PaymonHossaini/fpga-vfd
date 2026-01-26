// Simple DMA graphics test with strict cycle timing
// Same timing protocol as vfd_hello_strict.v that works perfectly

module vfd_dma_simple (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    localparam STATE_INIT           = 5'd0;
    localparam STATE_WAIT_RDY       = 5'd1;
    localparam STATE_WR_LOW         = 5'd2;
    localparam STATE_PUT_BYTE       = 5'd3;
    localparam STATE_WAIT_ONE       = 5'd4;
    localparam STATE_WAIT_TWO       = 5'd5;
    localparam STATE_WAIT_THREE     = 5'd6;
    localparam STATE_WR_HIGH        = 5'd7;
    localparam STATE_WAIT_RDY_LOW   = 5'd8;
    localparam STATE_NEXT           = 5'd9;
    localparam STATE_STREAM_WR_LOW  = 5'd10;  // DMA streaming - no ready check
    localparam STATE_STREAM_BYTE    = 5'd11;
    localparam STATE_STREAM_WAIT1   = 5'd12;
    localparam STATE_STREAM_WAIT2   = 5'd13;
    localparam STATE_STREAM_WAIT3   = 5'd14;
    localparam STATE_STREAM_WR_HIGH = 5'd15;
    localparam STATE_DONE           = 5'd16;
    
    reg [4:0] state;  // Need 5 bits now for states 0-15
    reg [23:0] counter;
    reg [23:0] timeout;
    reg [12:0] byte_idx;
    
    localparam NUM_BYTES = 13'd4104;  // 8 header + 4096 data
    localparam TIMEOUT = 24'd270000;  // 10ms timeout
    
    // ROM for image data (4096 bytes)
    wire [12:0] rom_addr = (byte_idx >= 8) ? (byte_idx - 8) : 13'd0;
    wire [7:0] rom_data;
    
    vfd_image_rom image_rom (
        .clk(clk),
        .addr(rom_addr),
        .data(rom_data)
    );
    
    reg [7:0] current_byte;
    
    always @(*) begin
        // DMA header
        if (byte_idx < 8) begin
            case (byte_idx)
                13'd0: current_byte = 8'h02;  // STX
                13'd1: current_byte = 8'h44;  // 'D'
                13'd2: current_byte = 8'h00;  // Xl
                13'd3: current_byte = 8'h46;  // Xh (70 = 0x46)
                13'd4: current_byte = 8'h00;  // Yl
                13'd5: current_byte = 8'h00;  // Yh
                13'd6: current_byte = 8'h00;  // Wl (256 = 0x100)
                13'd7: current_byte = 8'h01;  // Wh
                default: current_byte = 8'h00;
            endcase
        end else begin
            current_byte = rom_data;  // Image data from ROM
        end
    end
    
    always @(posedge clk) begin
        case (state)
            STATE_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_idx <= 13'd0;
                counter <= 24'd0;
                timeout <= 24'd0;
                leds <= 6'b000001;
                
                if (counter < 24'd2700000) begin // 100ms startup
                    counter <= counter + 1;
                end else begin
                    counter <= 24'd0;
                    state <= STATE_WAIT_RDY;
                end
            end
            
            // Cycle 1: Wait for ready HIGH
            STATE_WAIT_RDY: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                leds <= {ready, 5'b00010};
                
                if (ready == 1'b1 || timeout > TIMEOUT) begin
                    timeout <= 24'd0;
                    state <= STATE_WR_LOW;
                end else begin
                    timeout <= timeout + 1;
                end
            end
            
            // Cycle 2: Push WR LOW
            STATE_WR_LOW: begin
                wr_n <= 1'b0;  // WR goes LOW
                data_bus <= 8'h00;  // Bus still clear
                leds <= 6'b000100;
                state <= STATE_PUT_BYTE;
            end
            
            // Cycle 3: Put byte on bus (WR already LOW)
            STATE_PUT_BYTE: begin
                wr_n <= 1'b0;  // Keep WR LOW
                data_bus <= current_byte;  // Byte appears now
                leds <= 6'b001000;
                state <= STATE_WAIT_ONE;
            end
            
            // Cycle 4: Hold WR low
            STATE_WAIT_ONE: begin
                wr_n <= 1'b0;
                data_bus <= current_byte;
                leds <= 6'b010000;
                state <= STATE_WAIT_TWO;
            end
            
            // Cycle 5: Hold WR low
            STATE_WAIT_TWO: begin
                wr_n <= 1'b0;
                data_bus <= current_byte;
                leds <= 6'b010001;
                state <= STATE_WAIT_THREE;
            end
            
            // Cycle 6: Hold WR low + data
            STATE_WAIT_THREE: begin
                wr_n <= 1'b0;
                data_bus <= current_byte;
                leds <= 6'b010010;
                state <= STATE_WR_HIGH;
            end
            
            // Cycle 7: Push WR HIGH (LATCH on rising edge)
            STATE_WR_HIGH: begin
                wr_n <= 1'b1;  // WR goes HIGH
                data_bus <= current_byte;  // Keep data stable
                leds <= 6'b100000;
                timeout <= 24'd0;
                state <= STATE_WAIT_RDY_LOW;
            end
            
            // Cycle 8: Wait for ready LOW
            STATE_WAIT_RDY_LOW: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                leds <= {ready, 5'b10001};
                
                if (ready == 1'b0 || timeout > TIMEOUT) begin
                    timeout <= 24'd0;
                    state <= STATE_NEXT;
                end else begin
                    timeout <= timeout + 1;
                end
            end
            
            // Next byte
            STATE_NEXT: begin
                if (byte_idx < NUM_BYTES - 1) begin
                    byte_idx <= byte_idx + 1;
                    // After header (first 8 bytes), switch to streaming mode
                    if (byte_idx < 8) begin
                        state <= STATE_WAIT_RDY;  // Use handshaking for header
                    end else begin
                        state <= STATE_STREAM_WR_LOW;  // Stream data without ready checks
                    end
                end else begin
                    state <= STATE_DONE;
                end
            end
            
            // === DMA STREAMING MODE (no ready checks) ===
            STATE_STREAM_WR_LOW: begin
                wr_n <= 1'b0;
                data_bus <= 8'h00;
                leds <= 6'b000100;
                state <= STATE_STREAM_BYTE;
            end
            
            STATE_STREAM_BYTE: begin
                wr_n <= 1'b0;
                data_bus <= current_byte;
                leds <= 6'b001000;
                state <= STATE_STREAM_WAIT1;
            end
            
            STATE_STREAM_WAIT1: begin
                wr_n <= 1'b0;
                data_bus <= current_byte;
                leds <= 6'b010000;
                state <= STATE_STREAM_WAIT2;
            end
            
            STATE_STREAM_WAIT2: begin
                wr_n <= 1'b0;
                data_bus <= current_byte;
                leds <= 6'b010001;
                state <= STATE_STREAM_WAIT3;
            end
            
            STATE_STREAM_WAIT3: begin
                wr_n <= 1'b0;
                data_bus <= current_byte;
                leds <= 6'b010010;
                state <= STATE_STREAM_WR_HIGH;
            end
            
            STATE_STREAM_WR_HIGH: begin
                wr_n <= 1'b1;
                data_bus <= current_byte;
                leds <= 6'b100000;
                state <= STATE_NEXT;  // Go directly to next byte
            end
            
            // Done
            STATE_DONE: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                leds <= 6'b111111;  // All LEDs on when done
            end
        endcase
    end

endmodule
