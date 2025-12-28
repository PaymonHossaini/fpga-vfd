/*
 * Simple LED Blink Test for Tang Nano 20K
 * 
 * This is a minimal test to verify:
 * 1. The toolchain works (synthesis + place-route)
 * 2. Programming the FPGA works
 * 3. Basic I/O is functional
 *
 * Expected behavior: All 6 LEDs blink at ~1Hz
 * LEDs are active-low on Tang Nano 20K
 */

module led_blink_test (
    input  wire clk,        // 27 MHz crystal on pin 4
    output wire [5:0] led   // 6 LEDs on pins 15-20 (active low)
);

    // Counter for ~1 second delay at 27 MHz
    // 27,000,000 cycles = 1 second
    // We use bit 24 which toggles every ~0.6 seconds
    reg [25:0] counter;
    
    always @(posedge clk) begin
        counter <= counter + 1'b1;
    end
    
    // All LEDs blink together (active low, so invert)
    assign led = {6{counter[24]}};

endmodule
