// Pin Test Module - Verify all pins are working
// Each data pin will toggle at a different rate so you can probe them
// WR will pulse, ready state shown on LED5

module pin_test (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    reg [25:0] counter;
    
    always @(posedge clk) begin
        counter <= counter + 1;
    end
    
    // All pins set HIGH for voltage testing
    always @(posedge clk) begin
        data_bus[0] <= 1'b1;  // Pin 27 - should be 3.3V
        data_bus[1] <= 1'b1;  // Pin 28 - should be 3.3V
        data_bus[2] <= 1'b1;  // Pin 25 - should be 3.3V
        data_bus[3] <= 1'b1;  // Pin 26 - should be 3.3V
        data_bus[4] <= 1'b1;  // Pin 29 - should be 3.3V
        data_bus[5] <= 1'b1;  // Pin 30 - should be 3.3V
        data_bus[6] <= 1'b1;  // Pin 31 - should be 3.3V
        data_bus[7] <= 1'b1;  // Pin 42 - should be 3.3V
        
        wr_n <= 1'b1;  // Pin 41 - should be 3.3V
        
        // LEDs all on (active low, so 0 = on)
        leds[0] <= 1'b0;
        leds[1] <= 1'b0;
        leds[2] <= 1'b0;
        leds[3] <= 1'b0;
        leds[4] <= 1'b0;
        leds[5] <= ready;  // Shows ready signal state
    end
    
    initial begin
        counter = 26'd0;
        data_bus = 8'd0;
        wr_n = 1'b1;
        leds = 6'd0;
    end

endmodule
