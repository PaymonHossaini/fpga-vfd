// Debug ROM - outputs lower 8 bits of address
// This lets us verify addressing is correct
// Pattern repeats every 256 bytes (16 columns on display)
module vfd_image_rom (
    input wire clk,
    input wire [12:0] addr,
    output reg [7:0] data
);

    // Output addr % 256, so pattern repeats every 256 bytes
    // On display: 16 columns per pattern (16 bytes/col * 16 cols = 256)
    // Should see same pattern repeat 16 times across the screen
    always @(posedge clk) begin
        data <= addr[7:0];
    end

endmodule
