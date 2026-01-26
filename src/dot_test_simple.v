// VFD Single Dot Test - Testing y=6, y=7, y=8 rows
// Uses same simple state machine as hello_test
// Single dot command: 1F 28 64 10 01 xL xH yL yH

module vfd_image_display (
    input wire clk,           // 27MHz clock
    output reg [7:0] data_bus,
    output reg wr_n,          // Active low write strobe
    input wire ready,         // Active high when ready
    output wire [5:0] leds    // Onboard LEDs
);

    // States
    localparam INIT_DELAY = 0;
    localparam WAIT_READY = 1;
    localparam SETUP = 2;
    localparam PULSE = 3;
    localparam HOLD = 4;
    localparam NEXT = 5;
    localparam DONE = 6;

    // Timing counters at 27MHz
    localparam INIT_TIME = 27000000; // ~1 second startup delay
    localparam SETUP_TIME = 27;      // ~1us setup
    localparam PULSE_TIME = 54;      // ~2us WR pulse
    localparam HOLD_TIME = 27;       // ~1us hold
    localparam CHAR_DELAY = 810000;  // ~30ms between commands

    reg [2:0] state;
    reg [24:0] timer;
    reg [5:0] msg_idx;
    reg [23:0] led_counter;

    // Commands: ESC@ + CLR + 5 single dots at y=6,7,8,9,15
    reg [7:0] message [0:47];
    initial begin
        // ESC @ (init) and CLR
        message[0] = 8'h1B;  // ESC
        message[1] = 8'h40;  // @ (init)
        message[2] = 8'h0C;  // CLR
        
        // Dot at x=10, y=6
        message[3]  = 8'h1F;
        message[4]  = 8'h28;
        message[5]  = 8'h64;
        message[6]  = 8'h10;
        message[7]  = 8'h01;
        message[8]  = 8'h0A;  // x=10
        message[9]  = 8'h00;
        message[10] = 8'h06;  // y=6
        message[11] = 8'h00;
        
        // Dot at x=20, y=7
        message[12] = 8'h1F;
        message[13] = 8'h28;
        message[14] = 8'h64;
        message[15] = 8'h10;
        message[16] = 8'h01;
        message[17] = 8'h14;  // x=20
        message[18] = 8'h00;
        message[19] = 8'h07;  // y=7
        message[20] = 8'h00;
        
        // Dot at x=30, y=8
        message[21] = 8'h1F;
        message[22] = 8'h28;
        message[23] = 8'h64;
        message[24] = 8'h10;
        message[25] = 8'h01;
        message[26] = 8'h1E;  // x=30
        message[27] = 8'h00;
        message[28] = 8'h08;  // y=8
        message[29] = 8'h00;
        
        // Dot at x=40, y=9
        message[30] = 8'h1F;
        message[31] = 8'h28;
        message[32] = 8'h64;
        message[33] = 8'h10;
        message[34] = 8'h01;
        message[35] = 8'h28;  // x=40
        message[36] = 8'h00;
        message[37] = 8'h09;  // y=9
        message[38] = 8'h00;
        
        // Dot at x=50, y=15
        message[39] = 8'h1F;
        message[40] = 8'h28;
        message[41] = 8'h64;
        message[42] = 8'h10;
        message[43] = 8'h01;
        message[44] = 8'h32;  // x=50
        message[45] = 8'h00;
        message[46] = 8'h0F;  // y=15
        message[47] = 8'h00;
    end

    // LED blinks to show we're running
    assign leds[0] = led_counter[22];
    assign leds[5:1] = 5'b00000;

    initial begin
        state = INIT_DELAY;
        timer = 0;
        msg_idx = 0;
        data_bus = 8'h00;
        wr_n = 1;
        led_counter = 0;
    end

    always @(posedge clk) begin
        led_counter <= led_counter + 1;

        case (state)
            INIT_DELAY: begin
                wr_n <= 1;
                data_bus <= 8'h00;
                timer <= timer + 1;
                if (timer >= INIT_TIME) begin
                    timer <= 0;
                    state <= WAIT_READY;
                end
            end

            WAIT_READY: begin
                wr_n <= 1;
                if (msg_idx < 48) begin
                    data_bus <= message[msg_idx];
                    if (ready) begin
                        timer <= 0;
                        state <= SETUP;
                    end
                end else begin
                    state <= DONE;
                end
            end

            SETUP: begin
                timer <= timer + 1;
                if (timer >= SETUP_TIME) begin
                    wr_n <= 0;  // Assert WR
                    timer <= 0;
                    state <= PULSE;
                end
            end

            PULSE: begin
                timer <= timer + 1;
                if (timer >= PULSE_TIME) begin
                    wr_n <= 1;  // Release WR
                    timer <= 0;
                    state <= HOLD;
                end
            end

            HOLD: begin
                timer <= timer + 1;
                if (timer >= HOLD_TIME) begin
                    timer <= 0;
                    state <= NEXT;
                end
            end

            NEXT: begin
                timer <= timer + 1;
                if (timer >= CHAR_DELAY) begin
                    msg_idx <= msg_idx + 1;
                    timer <= 0;
                    state <= WAIT_READY;
                end
            end

            DONE: begin
                wr_n <= 1;
                data_bus <= 8'h00;
            end
        endcase
    end

endmodule
