// Simple Hello World test for VFD in character mode
// DIP switch 6 OFF = character mode

module vfd_image_display (
    input wire clk,           // 27MHz clock
    output reg [7:0] data_bus,
    output reg wr_n,          // Active low write strobe
    input wire ready,         // Active high when ready
    output wire [5:0] leds    // Onboard LEDs
);

    // Timing parameters at 27MHz (~37ns per cycle)
    localparam INIT_DELAY = 0;    // Startup delay state
    localparam WAIT_READY = 1;
    localparam SETUP = 2;
    localparam PULSE = 3;
    localparam HOLD = 4;
    localparam NEXT = 5;
    localparam DONE = 6;

    // Timing counters
    localparam INIT_TIME = 27000000; // ~1 second startup delay
    localparam SETUP_TIME = 2;    // ~74ns setup
    localparam PULSE_TIME = 3;    // ~111ns WR pulse
    localparam HOLD_TIME = 2;     // ~74ns hold
    localparam CHAR_DELAY = 27000; // ~1ms between chars

    reg [2:0] state;
    reg [24:0] timer;  // Larger timer for init delay
    reg [4:0] char_idx;
    reg [23:0] led_counter;

    // Test D0 bit - pairs that differ only in bit 0
    // If D0 works: "@ABCDEFG13579"
    // If D0 broken: "@@BBDDFF11335"
    reg [7:0] message [0:13];
    initial begin
        message[0] = 8'h0C;  // CLR - clear screen
        message[1] = 8'h40;  // @ (0100 0000)
        message[2] = 8'h41;  // A (0100 0001) - differs in bit 0
        message[3] = 8'h42;  // B (0100 0010)
        message[4] = 8'h43;  // C (0100 0011) - differs in bit 0
        message[5] = 8'h44;  // D (0100 0100)
        message[6] = 8'h45;  // E (0100 0101) - differs in bit 0
        message[7] = 8'h46;  // F (0100 0110)
        message[8] = 8'h47;  // G (0100 0111) - differs in bit 0
        message[9] = 8'h31;  // 1 (0011 0001) - differs in bit 0
        message[10] = 8'h33; // 3 (0011 0011) - differs in bit 0
        message[11] = 8'h35; // 5 (0011 0101) - differs in bit 0
        message[12] = 8'h37; // 7 (0011 0111) - differs in bit 0
        message[13] = 8'h39; // 9 (0011 1001) - differs in bit 0
    end

    // LED blinks to show we're running
    assign leds[0] = led_counter[22];
    assign leds[5:1] = 5'b00000;

    initial begin
        state = INIT_DELAY;
        timer = 0;
        char_idx = 0;
        data_bus = 8'h00;
        wr_n = 1;
        led_counter = 0;
    end

    always @(posedge clk) begin
        led_counter <= led_counter + 1;

        case (state)
            INIT_DELAY: begin
                // Wait 1 second after power-up before sending anything
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
                if (char_idx < 14) begin
                    data_bus <= message[char_idx];
                    if (ready) begin
                        timer <= 0;
                        state <= SETUP;
                    end
                end else begin
                    state <= DONE;
                end
            end

            SETUP: begin
                // Data setup time
                timer <= timer + 1;
                if (timer >= SETUP_TIME) begin
                    wr_n <= 0;  // Assert WR
                    timer <= 0;
                    state <= PULSE;
                end
            end

            PULSE: begin
                // WR pulse width
                timer <= timer + 1;
                if (timer >= PULSE_TIME) begin
                    wr_n <= 1;  // Release WR
                    timer <= 0;
                    state <= HOLD;
                end
            end

            HOLD: begin
                // Data hold time
                timer <= timer + 1;
                if (timer >= HOLD_TIME) begin
                    timer <= 0;
                    state <= NEXT;
                end
            end

            NEXT: begin
                // Delay between characters
                timer <= timer + 1;
                if (timer >= CHAR_DELAY) begin
                    char_idx <= char_idx + 1;
                    timer <= 0;
                    state <= WAIT_READY;
                end
            end

            DONE: begin
                // All done, just idle
                wr_n <= 1;
                data_bus <= 8'h00;
            end
        endcase
    end

endmodule
