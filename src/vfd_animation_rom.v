// VFD Animation ROM - loads all frames from hex file
module vfd_animation_rom (
    input wire clk,
    input wire [13:0] addr,  // 14 bits for 16384 bytes
    output reg [7:0] data
);

    // 4 frames × 4096 bytes = 16384 bytes total
    reg [7:0] mem [0:16383];

    initial begin
        $readmemh("src/vfd_animation_rom.hex", mem);
    end

    always @(posedge clk) begin
        data <= mem[addr];
    end

endmodule
