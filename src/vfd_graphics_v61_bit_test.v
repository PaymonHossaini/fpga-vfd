// VFD Graphics Test v61 - Test each bit individually
// Cycles through one bit at a time so we can verify each data line

module vfd_graphics_v61_bit_test (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    reg [27:0] counter;
    reg [2:0] bit_select;
    
    always @(posedge clk) begin
        counter <= counter + 1;
        
        // Change bit every ~1.6 seconds (27MHz * 1.6s ≈ 43M cycles)
        if (counter >= 28'd43000000) begin
            counter <= 28'd0;
            bit_select <= bit_select + 1;  // Cycle through 0-7 then repeat
        end
        
        // Set only one bit HIGH at a time
        case (bit_select)
            3'd0: data_bus <= 8'b00000001;  // Bit 0
            3'd1: data_bus <= 8'b00000010;  // Bit 1
            3'd2: data_bus <= 8'b00000100;  // Bit 2
            3'd3: data_bus <= 8'b00001000;  // Bit 3
            3'd4: data_bus <= 8'b00010000;  // Bit 4
            3'd5: data_bus <= 8'b00100000;  // Bit 5
            3'd6: data_bus <= 8'b01000000;  // Bit 6
            3'd7: data_bus <= 8'b10000000;  // Bit 7
        endcase
        
        wr_n <= 1'b1;  // Keep write disabled
        leds <= {bit_select, 3'b000};  // Show which bit on LEDs
    end

endmodule
