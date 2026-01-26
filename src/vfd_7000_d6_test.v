// GU-7000 D6/D7 Test
// Holds 0x40 (01000000) - only D6 should be HIGH

module vfd_7000_d6_test (
    input wire clk,
    output wire [7:0] data_bus,
    output wire wr_n,
    input wire busy,
    output wire [5:0] leds
);

    // 0x40 = 01000000
    // D0=0, D1=0, D2=0, D3=0, D4=0, D5=0, D6=1, D7=0
    assign data_bus = 8'h40;
    
    assign wr_n = 1'b1;
    assign leds = 6'b010000;  // LED pattern matches D6

endmodule
