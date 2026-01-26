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
    
    // Output 0x0F (00001111) to test byte ordering
    // Lower 4 bits = 0, Upper 4 bits = 1
    always @(posedge clk) begin
        data_bus <= 8'h0F;  // 00001111 pattern
        wr_n <= 1'b1;       // WR high (inactive)
        
        // LEDs show pattern
        leds[0] <= 1'b1;    // off
        leds[1] <= 1'b1;    // off
        leds[2] <= 1'b1;    // off
        leds[3] <= 1'b1;    // off
        leds[4] <= 1'b0;    // on
        leds[5] <= ready;   // Shows ready signal state
    end
    
    initial begin
        counter = 26'd0;
        data_bus = 8'd0;
        wr_n = 1'b1;
        leds = 6'd0;
    end

endmodule
