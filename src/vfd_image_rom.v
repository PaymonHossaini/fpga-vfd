// VFD Image ROM - Column-based debug pattern
// Each column shows its X coordinate to verify addressing

module vfd_image_rom (
    input wire [12:0] addr,
    output reg [7:0] data
);

    // addr = x * 16 + y_byte
    // x = addr[12:4] (column 0-255)
    // y_byte = addr[3:0] (row byte 0-15)
    
    wire [7:0] x_col = addr[12:4];
    
    // Output pattern varies by column:
    // Every 8th column is FF, rest are 00
    // This should show vertical stripes spaced 8 pixels apart
    always @(*) begin
        if (x_col[2:0] == 3'b000)
            data = 8'hFF;  // Columns 0, 8, 16, 24, ... are lit
        else
            data = 8'h00;  // Others are dark
    end

endmodule
