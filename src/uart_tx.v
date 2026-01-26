// Simple UART transmitter
// 115200 baud at 27MHz clock
module uart_tx (
    input wire clk,
    input wire [7:0] data,
    input wire start,
    output reg tx,
    output reg busy
);

    // 27MHz / 115200 = 234 cycles per bit
    localparam CLKS_PER_BIT = 234;
    
    reg [7:0] shift_reg;
    reg [3:0] bit_idx;
    reg [7:0] clk_count;
    reg [1:0] state;
    
    localparam IDLE = 2'd0;
    localparam START_BIT = 2'd1;
    localparam DATA_BITS = 2'd2;
    localparam STOP_BIT = 2'd3;
    
    initial begin
        tx = 1'b1;
        busy = 1'b0;
        state = IDLE;
        clk_count = 0;
        bit_idx = 0;
        shift_reg = 0;
    end
    
    always @(posedge clk) begin
        case (state)
            IDLE: begin
                tx <= 1'b1;
                busy <= 1'b0;
                clk_count <= 0;
                bit_idx <= 0;
                if (start) begin
                    shift_reg <= data;
                    busy <= 1'b1;
                    state <= START_BIT;
                end
            end
            
            START_BIT: begin
                tx <= 1'b0;  // Start bit is low
                if (clk_count < CLKS_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    state <= DATA_BITS;
                end
            end
            
            DATA_BITS: begin
                tx <= shift_reg[0];  // LSB first
                if (clk_count < CLKS_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    shift_reg <= {1'b0, shift_reg[7:1]};  // Shift right
                    if (bit_idx < 7) begin
                        bit_idx <= bit_idx + 1;
                    end else begin
                        bit_idx <= 0;
                        state <= STOP_BIT;
                    end
                end
            end
            
            STOP_BIT: begin
                tx <= 1'b1;  // Stop bit is high
                if (clk_count < CLKS_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    state <= IDLE;
                end
            end
        endcase
    end

endmodule
