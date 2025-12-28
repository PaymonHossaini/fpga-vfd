// VFD Graphics Test v60 - All bus values held HIGH (no toggling)
// Simple static test to verify all bits can drive high voltage

module vfd_graphics_v60_all_ones_static (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    always @(posedge clk) begin
        // Hold all data lines HIGH (0xFF)
        data_bus <= 8'hFF;
        wr_n <= 1'b1;  // Keep write disabled
        leds <= 6'b111111;  // All LEDs on to show it's running
    end

endmodule
