// VFD Stream Display - Receives frames over UART and displays them
// No buffer: display bytes directly as they arrive from UART
// PC controls timing by waiting between frames

module vfd_image_display (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds,
    output wire uart_tx_pin,
    input wire uart_rx_pin
);

    assign uart_tx_pin = 1'b1;  // Not used for TX

    // States
    localparam S_INIT       = 4'd0;
    localparam S_HDR_SETUP  = 4'd1;
    localparam S_HDR_WR_LO  = 4'd2;
    localparam S_HDR_WR_HI  = 4'd3;
    localparam S_HDR_DELAY  = 4'd4;
    localparam S_HDR_NEXT   = 4'd5;
    localparam S_WAIT_BYTE  = 4'd6;   // Wait for UART byte
    localparam S_DMA_WR_LO  = 4'd7;
    localparam S_DMA_WR_HI  = 4'd8;
    localparam S_DMA_NEXT   = 4'd9;
    
    reg [3:0] state;
    reg [23:0] counter;
    reg [15:0] timer;
    reg [12:0] byte_idx;
    reg [7:0] latched_byte;
    
    // Header timing
    localparam HDR_TIME  = 16'd270;
    localparam HDR_DELAY = 16'd2700;
    localparam HDR_LONG  = 16'd54000;
    localparam NUM_HEADER = 13'd8;
    localparam BYTES_PER_FRAME = 13'd4096;
    
    // UART receiver
    wire [7:0] uart_data;
    wire uart_valid;
    wire uart_busy;
    
    uart_rx #(
        .CLK_FREQ(27000000),
        .BAUD_RATE(1000000)
    ) uart_receiver (
        .clk(clk),
        .rx(uart_rx_pin),
        .data(uart_data),
        .valid(uart_valid),
        .busy(uart_busy)
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
    
    // Main state machine
    always @(posedge clk) begin
        case (state)
            S_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_idx <= 0;
                timer <= 0;
                leds <= 6'b000001;
                // Short startup delay
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
                    state <= S_WAIT_BYTE;
                end
            end
            
            // === DMA DATA - direct from UART ===
            S_WAIT_BYTE: begin
                wr_n <= 1'b1;
                leds <= {1'b1, byte_idx[12:8]};  // Show progress
                
                if (uart_valid) begin
                    latched_byte <= uart_data;
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
                    state <= S_WAIT_BYTE;
                end else begin
                    // Frame done, start next frame header
                    byte_idx <= 0;
                    state <= S_HDR_SETUP;
                end
            end
            
            default: state <= S_INIT;
        endcase
    end
    
    initial begin
        state = S_INIT;
        counter = 0;
        timer = 0;
        byte_idx = 0;
        wr_n = 1'b1;
        data_bus = 8'h00;
        leds = 6'b0;
        latched_byte = 8'h00;
    end

endmodule
