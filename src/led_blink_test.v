/*
 * Simple LED Blink Test for Tang Nano 20K
 * Uses onboard crystal oscillator (27 MHz) and onboard LEDs
 * LEDs are active-low (output 0 = LED ON)
 */

module led_blink_test (
    input  wire clk,        // 27 MHz crystal on Pin 4
    output wire led0,       // Pin 15
    output wire led1,       // Pin 16
    output wire led2,       // Pin 17
    output wire led3,       // Pin 18
    output wire led4,       // Pin 19
    output wire led5        // Pin 20
);

    // Counter for timing (27MHz = 27,000,000 cycles per second)
    // To blink at ~1Hz, we need to count to 13,500,000 for 0.5s
    reg [25:0] counter;
    
    // LED state register
    reg [5:0] led_state;
    
    // Initialize
    initial begin
        counter = 0;
        led_state = 6'b111110;  // Start with LED0 on (active low)
    end
    
    always @(posedge clk) begin
        counter <= counter + 1;
        
        // Every ~0.5 seconds (13.5M cycles at 27MHz), rotate the LED pattern
        if (counter == 26'd13_500_000) begin
            counter <= 0;
            // Rotate LED pattern (like a chaser)
            led_state <= {led_state[4:0], led_state[5]};
        end
    end
    
    // Output LED states (directly from register)
    assign led0 = led_state[0];
    assign led1 = led_state[1];
    assign led2 = led_state[2];
    assign led3 = led_state[3];
    assign led4 = led_state[4];
    assign led5 = led_state[5];

endmodule
