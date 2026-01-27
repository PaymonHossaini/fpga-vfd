// VFD UART Streaming Display - Direct stream to VFD
// No buffer needed - bytes go directly from UART to VFD
// PC sends frames at the pace the FPGA can display them
//
// Protocol:
// - Send 4-byte sync: 0xAA 0x55 0xAA 0x55
// - Then send 4096 data bytes

module vfd_image_display (
    input wire clk,                  // 27MHz
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds,
    output wire uart_tx_pin,
    input wire uart_rx_pin
);

    assign uart_tx_pin = 1'b1;  // Idle high, not used

    // ========== UART Receiver ==========
    wire [7:0] uart_rx_data;
    wire uart_rx_valid;
    
    uart_rx #(
        .CLK_FREQ(27000000),
        .BAUD_RATE(1000000)
    ) uart_inst (
        .clk(clk),
        .rx(uart_rx_pin),
        .data(uart_rx_data),
        .valid(uart_rx_valid),
        .busy()
    );

    // ========== State Machine ==========
    localparam BYTES_PER_FRAME = 4096;
    
    localparam S_WAIT_SYNC0    = 4'd0;   // Wait for 0xAA
    localparam S_WAIT_SYNC1    = 4'd1;   // Wait for 0x55
    localparam S_WAIT_SYNC2    = 4'd2;   // Wait for 0xAA
    localparam S_WAIT_SYNC3    = 4'd3;   // Wait for 0x55
    localparam S_HDR_SETUP     = 4'd4;
    localparam S_HDR_WR_LO     = 4'd5;
    localparam S_HDR_WR_HI     = 4'd6;
    localparam S_HDR_DELAY     = 4'd7;
    localparam S_HDR_NEXT      = 4'd8;
    localparam S_WAIT_BYTE     = 4'd9;   // Wait for UART data byte
    localparam S_DMA_WR_LO     = 4'd10;
    localparam S_DMA_WR_HI     = 4'd11;
    localparam S_DMA_NEXT      = 4'd12;
    localparam S_FRAME_DONE    = 4'd13;
    
    reg [3:0] state;
    reg [15:0] timer;
    reg [12:0] byte_idx;
    
    // Header timing at 27MHz
    localparam HDR_TIME  = 16'd270;    // ~10us
    localparam HDR_DELAY = 16'd2700;   // ~100us
    localparam HDR_LONG  = 16'd54000;  // ~2ms
    
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
            // === 4-BYTE SYNC PATTERN: 0xAA 0x55 0xAA 0x55 ===
            S_WAIT_SYNC0: begin
                wr_n <= 1'b1;
                byte_idx <= 0;
                timer <= 0;
                leds <= 6'b000001;
                if (uart_rx_valid) begin
                    if (uart_rx_data == 8'hAA)
                        state <= S_WAIT_SYNC1;
                end
            end
            
            S_WAIT_SYNC1: begin
                if (uart_rx_valid) begin
                    if (uart_rx_data == 8'h55)
                        state <= S_WAIT_SYNC2;
                    else if (uart_rx_data == 8'hAA)
                        state <= S_WAIT_SYNC1;  // Stay here if another AA
                    else
                        state <= S_WAIT_SYNC0;  // Reset
                end
            end
            
            S_WAIT_SYNC2: begin
                if (uart_rx_valid) begin
                    if (uart_rx_data == 8'hAA)
                        state <= S_WAIT_SYNC3;
                    else
                        state <= S_WAIT_SYNC0;  // Reset
                end
            end
            
            S_WAIT_SYNC3: begin
                if (uart_rx_valid) begin
                    if (uart_rx_data == 8'h55) begin
                        state <= S_HDR_SETUP;
                        leds <= 6'b000010;
                    end else if (uart_rx_data == 8'hAA)
                        state <= S_WAIT_SYNC1;  // Might be start of new pattern
                    else
                        state <= S_WAIT_SYNC0;  // Reset
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
                timer <= timer + 1;
                if (timer >= (byte_idx < 2 ? HDR_LONG : HDR_DELAY)) begin
                    timer <= 0;
                    state <= S_HDR_NEXT;
                end
            end
            
            S_HDR_NEXT: begin
                byte_idx <= byte_idx + 1;
                if (byte_idx >= 7) begin
                    byte_idx <= 0;
                    state <= S_WAIT_BYTE;
                    leds <= 6'b000100;
                end else begin
                    state <= S_HDR_SETUP;
                end
            end
            
            // === DMA DATA ===
            S_WAIT_BYTE: begin
                // Wait for UART byte
                if (uart_rx_valid) begin
                    data_bus <= uart_rx_data;
                    timer <= 0;
                    state <= S_DMA_WR_LO;
                end
            end
            
            S_DMA_WR_LO: begin
                wr_n <= 1'b0;
                timer <= timer + 1;
                if (timer >= 16'd2) begin  // Hold WR low for a bit
                    timer <= 0;
                    state <= S_DMA_WR_HI;
                end
            end
            
            S_DMA_WR_HI: begin
                wr_n <= 1'b1;
                timer <= timer + 1;
                if (timer >= 16'd2) begin  // Hold WR high for a bit
                    timer <= 0;
                    state <= S_DMA_NEXT;
                end
            end
            
            S_DMA_NEXT: begin
                byte_idx <= byte_idx + 1;
                if (byte_idx >= BYTES_PER_FRAME - 1) begin
                    // Frame complete
                    byte_idx <= 0;
                    state <= S_FRAME_DONE;
                    leds <= 6'b001000;
                end else begin
                    state <= S_WAIT_BYTE;
                end
            end
            
            S_FRAME_DONE: begin
                // Frame complete, go back to waiting for sync
                state <= S_WAIT_SYNC0;
                leds <= 6'b010000;
            end
            
            default: state <= S_WAIT_SYNC0;
        endcase
    end

endmodule
