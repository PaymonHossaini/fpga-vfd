// VFD Graphics Test v62 - All bus values held LOW (0V)
// Simple static test to verify all bits can drive low voltage

module vfd_graphics_v62_all_zeros_static (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    always @(posedge clk) begin
        // Hold all data lines LOW (0x00)
        data_bus <= 8'h00;
        wr_n <= 1'b1;  // Keep write disabled
        leds <= 6'b111111;  // All LEDs on to show it's running
    end

endmodule
