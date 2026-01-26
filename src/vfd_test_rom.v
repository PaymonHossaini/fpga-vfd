// VFD Test ROM - outputs address as data
// This will create a predictable gradient pattern

module vfd_test_rom (
    input wire clk,
    input wire [12:0] addr,
    output reg [7:0] data
);

    // Just output the low 8 bits of address
    // This creates a repeating 0-255 pattern
    always @(posedge clk) begin
        data <= addr[7:0];
    end

endmodule
