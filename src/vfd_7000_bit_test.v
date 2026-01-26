// GU-7000 Bit Order Test
// Sends 0x55 (01010101) = 'U' if correct
// If bits reversed, 0xAA would display something else

module vfd_7000_bit_test (
    input wire clk,           // 27MHz
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire busy,
    output reg [5:0] leds
);

    localparam WR_LOW_CYCLES = 8;
    localparam POST_DELAY_CYCLES = 600;

    localparam STATE_INIT       = 4'd0;
    localparam STATE_WAIT_BUSY  = 4'd1;
    localparam STATE_SETUP_DATA = 4'd2;
    localparam STATE_WR_LOW     = 4'd3;
    localparam STATE_WR_HIGH    = 4'd4;
    localparam STATE_POST_DELAY = 4'd5;
    localparam STATE_NEXT       = 4'd6;
    localparam STATE_DONE       = 4'd7;

    reg [3:0] state;
    reg [3:0] byte_index;
    reg [23:0] counter;
    reg [31:0] timeout;

    // Test pattern: 0x55 ('U'), 0xAA, 0x0F, 0xF0
    wire [7:0] cmd_data [0:3];
    assign cmd_data[0] = 8'h55;  // 01010101 = 'U'
    assign cmd_data[1] = 8'hAA;  // 10101010
    assign cmd_data[2] = 8'h0F;  // 00001111
    assign cmd_data[3] = 8'hF0;  // 11110000

    initial begin
        state = STATE_INIT;
        byte_index = 0;
        counter = 0;
        timeout = 0;
        data_bus = 8'h00;
        wr_n = 1'b1;
        leds = 6'b000001;
    end

    always @(posedge clk) begin
        case (state)
            STATE_INIT: begin
                counter <= counter + 1;
                if (counter >= 24'd2_700_000) begin
                    counter <= 0;
                    byte_index <= 0;
                    state <= STATE_WAIT_BUSY;
                end
            end

            STATE_WAIT_BUSY: begin
                timeout <= timeout + 1;
                leds[5] <= busy;
                
                if (busy == 1'b0 || timeout >= 27_000_000) begin
                    timeout <= 0;
                    state <= STATE_SETUP_DATA;
                end
            end

            STATE_SETUP_DATA: begin
                data_bus <= cmd_data[byte_index];
                counter <= 0;
                state <= STATE_WR_LOW;
            end

            STATE_WR_LOW: begin
                wr_n <= 1'b0;
                counter <= counter + 1;
                if (counter >= WR_LOW_CYCLES) begin
                    counter <= 0;
                    state <= STATE_WR_HIGH;
                end
            end

            STATE_WR_HIGH: begin
                wr_n <= 1'b1;
                counter <= 0;
                state <= STATE_POST_DELAY;
            end

            STATE_POST_DELAY: begin
                counter <= counter + 1;
                if (counter >= POST_DELAY_CYCLES) begin
                    counter <= 0;
                    state <= STATE_NEXT;
                end
            end

            STATE_NEXT: begin
                if (byte_index >= 3) begin
                    state <= STATE_DONE;
                    leds <= 6'b111111;
                end else begin
                    byte_index <= byte_index + 1;
                    state <= STATE_WAIT_BUSY;
                end
            end

            STATE_DONE: begin
                wr_n <= 1'b1;
            end
        endcase
    end

endmodule
