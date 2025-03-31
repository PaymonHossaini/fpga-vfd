module vfd_test_writer(
    input wire clk,
    output reg [7:0] data_bus,
    output wire led,            // Debug LED output (active-low)
    output wire led_ready,      // READY signal indicator LED (active-low)
    output wire led_state1,     // State 1 indicator LED (active-low)
    output wire led_state0,     // State 0 indicator LED (active-low)
    output reg wr_n,
    input wire ready            // VFD READY signal
);

    reg [3:0] state;
    reg [31:0] delay_counter;
    reg led_internal;
    reg [7:0] char_buffer [0:7];
    reg [31:0] char_index;
    reg flipped;

    assign led = flipped;
    assign led_ready = ready;
    assign led_state1 = (state == 1) ? 1'b0 : 1'b1;
    assign led_state0 = (state == 0) ? 1'b0 : 1'b1;


    initial begin
        state = 4'd0; // start in wait-for-ready-low state
        delay_counter = 31'd0;
        led_internal = 1'b0;
        char_index = 3'd0;
        data_bus = 8'hFF;
        wr_n = 1'b1;
        flipped = 1'b0;
        char_buffer[0] = 8'h0C;
//        char_buffer[0] = "P";
        char_buffer[1] = "H";
        char_buffer[2] = "E";
        char_buffer[3] = "L";
        char_buffer[4] = "L";
        char_buffer[5] = "O";
        char_buffer[6] = "Q";
        char_buffer[7] = "X";
    end
//data_bus <= 8'hFF;
    always @(posedge clk) begin
        case (state)
            0: begin // waits for ready signal and writes a bit then sets write low
                if (ready) begin
                    data_bus <= char_buffer[char_index];
                    state <= 1;
                end
            end
            1: begin
                if (ready) begin
                    wr_n <= 0;
                    delay_counter <= delay_counter + 1;
                    if (delay_counter == 5) begin
                        state <= 2;
                        delay_counter <= 0;
                        wr_n <= 1;
                    end
                end
            end
            2: begin
                if (ready) begin
                    state <= 0;
                    flipped <= 0;
                    char_index <= char_index + 1;
                    if (char_index == 3'd7) begin
                        state <= 3;
                    end
                end
            end
            3: begin
                data_bus <= 8'hFF;
                delay_counter <= delay_counter + 1;
                if (delay_counter[24]) begin
                    led_internal <= ~led_internal;
                end
            end
        endcase
    end

endmodule
