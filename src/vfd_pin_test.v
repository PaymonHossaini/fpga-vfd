// Simple pin test - all data pins HIGH
// Just sets data_bus to 0xFF so you can verify level shifter with multimeter

module vfd_pin_test (
    input wire clk,
    output wire [7:0] data_bus,
    output wire wr_n,
    input wire ready,
    output wire [5:0] leds
);

    // All data pins LOW (should read ~0V after level shifter)
    assign data_bus = 8'h55;
    
    // WR HIGH (should read 3.3V on pin 41)
    assign wr_n = 1'b1;
    
    // LEDs show we're running
    assign leds = 6'b000000;

endmodule
