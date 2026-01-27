// UART Receiver Module
// 27MHz clock, configurable baud rate

module uart_rx #(
    parameter CLK_FREQ = 27000000,
    parameter BAUD_RATE = 1000000
)(
    input wire clk,
    input wire rx,
    output reg [7:0] data,
    output reg valid,  // Pulses high for one cycle when byte received
    output reg busy
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT = CLKS_PER_BIT / 2;
    
    localparam S_IDLE  = 2'd0;
    localparam S_START = 2'd1;
    localparam S_DATA  = 2'd2;
    localparam S_STOP  = 2'd3;
    
    reg [1:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_idx;
    reg [7:0] rx_byte;
    reg rx_sync1, rx_sync2;  // Synchronizer for RX input
    
    // Double-flop synchronizer for metastability
    always @(posedge clk) begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end
    
    always @(posedge clk) begin
        valid <= 1'b0;  // Default: no valid data
        
        case (state)
            S_IDLE: begin
                busy <= 1'b0;
                clk_count <= 0;
                bit_idx <= 0;
                
                // Detect start bit (falling edge)
                if (rx_sync2 == 1'b0) begin
                    state <= S_START;
                    busy <= 1'b1;
                end
            end
            
            S_START: begin
                // Wait for middle of start bit
                if (clk_count < HALF_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    // Verify still low (valid start bit)
                    if (rx_sync2 == 1'b0) begin
                        clk_count <= 0;
                        state <= S_DATA;
                    end else begin
                        // False start, go back to idle
                        state <= S_IDLE;
                    end
                end
            end
            
            S_DATA: begin
                // Wait for middle of data bit
                if (clk_count < CLKS_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    rx_byte[bit_idx] <= rx_sync2;  // LSB first
                    
                    if (bit_idx < 7) begin
                        bit_idx <= bit_idx + 1;
                    end else begin
                        bit_idx <= 0;
                        state <= S_STOP;
                    end
                end
            end
            
            S_STOP: begin
                // Wait for stop bit
                if (clk_count < CLKS_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    // Output the received byte
                    data <= rx_byte;
                    valid <= 1'b1;
                    state <= S_IDLE;
                end
            end
            
            default: state <= S_IDLE;
        endcase
    end
    
    initial begin
        state = S_IDLE;
        clk_count = 0;
        bit_idx = 0;
        rx_byte = 8'd0;
        data = 8'd0;
        valid = 1'b0;
        busy = 1'b0;
        rx_sync1 = 1'b1;
        rx_sync2 = 1'b1;
    end

endmodule
