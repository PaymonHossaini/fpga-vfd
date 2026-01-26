// GU-7000 Proper Init Test
// First sends Initialize (0x1B, 0x40) then "ABCD"

module vfd_7000_init_test (
    input wire clk,           // 27MHz
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire busy,
    output reg [5:0] leds
);

    localparam WR_LOW_CYCLES = 3;         // ~110ns (Arduino uses 0.11us)
    localparam POST_DELAY_CYCLES = 540;   // ~20us (Arduino uses 20us)
    localparam INIT_DELAY = 27_000_000;   // 1 second after init command

    localparam STATE_STARTUP    = 4'd0;
    localparam STATE_WAIT_BUSY  = 4'd1;
    localparam STATE_SETUP_DATA = 4'd2;
    localparam STATE_WR_LOW     = 4'd3;
    localparam STATE_WR_HIGH    = 4'd4;
    localparam STATE_POST_DELAY = 4'd5;
    localparam STATE_NEXT       = 4'd6;
    localparam STATE_INIT_WAIT  = 4'd7;
    localparam STATE_DONE       = 4'd8;

    reg [3:0] state;
    reg [3:0] byte_index;
    reg [31:0] counter;
    reg [31:0] timeout;

    // Command sequence:
    // 0x1B, 0x40 = Initialize Display
    // 0x0C = Display Clear (clears screen, cursor home)
    // then "ABCD"
    wire [7:0] cmd_data [0:6];
    assign cmd_data[0] = 8'h1B;  // ESC
    assign cmd_data[1] = 8'h40;  // @ (Initialize)
    assign cmd_data[2] = 8'h0C;  // Display Clear
    assign cmd_data[3] = 8'h41;  // 'A'
    assign cmd_data[4] = 8'h42;  // 'B'
    assign cmd_data[5] = 8'h43;  // 'C'
    assign cmd_data[6] = 8'h44;  // 'D'

    initial begin
        state = STATE_STARTUP;
        byte_index = 0;
        counter = 0;
        timeout = 0;
        data_bus = 8'h00;
        wr_n = 1'b1;
        leds = 6'b000001;
    end

    always @(posedge clk) begin
        case (state)
            STATE_STARTUP: begin
                // 500ms startup delay before anything
                counter <= counter + 1;
                if (counter >= 32'd13_500_000) begin
                    counter <= 0;
                    byte_index <= 0;
                    state <= STATE_WAIT_BUSY;
                    leds <= 6'b000010;
                end
            end

            STATE_WAIT_BUSY: begin
                timeout <= timeout + 1;
                leds[5] <= busy;
                
                if (busy == 1'b0 || timeout >= 27_000_000) begin
                    timeout <= 0;
                    state <= STATE_SETUP_DATA;
                    leds <= 6'b000100;
                end
            end

            STATE_SETUP_DATA: begin
                data_bus <= cmd_data[byte_index];
                counter <= 0;
                state <= STATE_WR_LOW;
                leds <= 6'b001000;
            end

            STATE_WR_LOW: begin
                wr_n <= 1'b0;
                counter <= counter + 1;
                if (counter >= WR_LOW_CYCLES) begin
                    counter <= 0;
                    state <= STATE_WR_HIGH;
                    leds <= 6'b010000;
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
                // After sending init command (byte 1), wait longer
                if (byte_index == 1) begin
                    state <= STATE_INIT_WAIT;
                    counter <= 0;
                end else if (byte_index >= 6) begin
                    state <= STATE_DONE;
                    leds <= 6'b100000;
                end else begin
                    byte_index <= byte_index + 1;
                    state <= STATE_WAIT_BUSY;
                    leds <= 6'b000010;
                end
            end

            STATE_INIT_WAIT: begin
                // Wait 1 second after init command
                counter <= counter + 1;
                if (counter >= INIT_DELAY) begin
                    counter <= 0;
                    byte_index <= byte_index + 1;
                    state <= STATE_WAIT_BUSY;
                end
            end

            STATE_DONE: begin
                leds <= 6'b111111;
                wr_n <= 1'b1;
            end
        endcase
    end

endmodule
