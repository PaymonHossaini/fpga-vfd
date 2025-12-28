// VFD Graphics Test v63 - Alternating 1s and 0s
// Pattern 0xAA (10101010) to verify no bits are inverted

module vfd_graphics_v63_alternating (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    always @(posedge clk) begin
        // Hold alternating pattern: 1 0 1 0 1 0 1 0
        data_bus <= 8'hAA;  // 0b10101010
        wr_n <= 1'b1;  // Keep write disabled
        leds <= 6'b111111;  // All LEDs on to show it's running
    end

endmodule
