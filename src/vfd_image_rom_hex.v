// VFD Image ROM using $readmemh
module vfd_image_rom (
    input wire clk,
    input wire [12:0] addr,
    output reg [7:0] data
);

    reg [7:0] mem [0:4095];

    initial begin
        $readmemh("src/vfd_image_rom.hex", mem);
    end

    always @(posedge clk) begin
        data <= mem[addr];
    end

endmodule
