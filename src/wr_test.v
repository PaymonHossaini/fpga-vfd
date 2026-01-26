// WR Signal Test - Continuously pulse WR with constant data
// Lets you probe WR signal with scope/multimeter

module wr_test (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    reg [23:0] counter;
    reg [15:0] pulse_timer;
    reg state;
    
    localparam STATE_HIGH = 1'b0;
    localparam STATE_LOW  = 1'b1;
    
    // Timing: visible WR pulses
    localparam PULSE_HIGH = 16'd13500;  // ~500us high
    localparam PULSE_LOW  = 16'd13500;  // ~500us low
    
    always @(posedge clk) begin
        // Constant test pattern on data bus
        data_bus <= 8'hAA;  // 10101010 pattern
        
        // Pulse WR continuously
        case (state)
            STATE_HIGH: begin
                wr_n <= 1'b1;
                leds <= 6'b000001;
                
                if (pulse_timer < PULSE_HIGH) begin
                    pulse_timer <= pulse_timer + 1;
                end else begin
                    pulse_timer <= 16'd0;
                    state <= STATE_LOW;
                end
            end
            
            STATE_LOW: begin
                wr_n <= 1'b0;
                leds <= 6'b000010;
                
                if (pulse_timer < PULSE_LOW) begin
                    pulse_timer <= pulse_timer + 1;
                end else begin
                    pulse_timer <= 16'd0;
                    state <= STATE_HIGH;
                end
            end
        endcase
    end
    
    initial begin
        counter = 24'd0;
        pulse_timer = 16'd0;
        state = STATE_HIGH;
        wr_n = 1'b1;
        data_bus = 8'd0;
        leds = 6'd0;
    end

endmodule
