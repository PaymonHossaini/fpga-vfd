// Simple bus test - hold all signals high to verify level shifters
module vfd_image_display (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    reg [23:0] counter;

    always @(posedge clk) begin
        counter <= counter + 1;
        
        // Hold data bus - edit bits directly: D7 D6 D5 D4 D3 D2 D1 D0
        data_bus <= 8'b00000001;
        
        // Hold WR high (inactive)
        wr_n <= 1'b1;
        
        // Blink LED to show we're running
        leds <= {5'b00000, counter[23]};
    end

endmodule
