// VFD White Screen ROM - All 0xFF
// Total bytes: 4096

module vfd_image_rom (
    input wire clk,
    input wire [12:0] addr,
    output reg [7:0] data
);

    // Just output 0xFF for all addresses - full white screen
    always @(posedge clk) begin
        data <= 8'hFF;
    end

endmodule
