// VFD Graphics Test v26 - Flush buffer with nulls before initialize
// The receive buffer persists across FPGA reprogramming!
// Send many 0x00 bytes to flush any partial commands, then init

module vfd_graphics_v26 (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    localparam STATE_INIT      = 3'd0;
    localparam STATE_WAIT_RDY  = 3'd1;
    localparam STATE_SETUP     = 3'd2;
    localparam STATE_PULSE_WR  = 3'd3;
    localparam STATE_HOLD      = 3'd4;
    localparam STATE_NEXT      = 3'd5;
    localparam STATE_DONE      = 3'd6;
    
    reg [2:0] state;
    reg [23:0] counter;
    reg [19:0] delay_counter;
    reg [7:0] wr_timer;
    reg [7:0] byte_idx;  // Wider to handle more bytes
    
    // 64 nulls + Initialize (1B 40) + Clear (0C) + Graphics command + 8 data bytes
    // 64 + 2 + 1 + 9 + 8 = 84 bytes
    localparam NUM_BYTES = 8'd84;
    localparam NUM_NULLS = 8'd64;
    
    reg [7:0] current_byte;
    
    always @(*) begin
        if (byte_idx < NUM_NULLS) begin
            // First 64 bytes: nulls to flush buffer
            current_byte = 8'h00;
        end else begin
            case (byte_idx - NUM_NULLS)
                // Initialize display
                8'd0: current_byte = 8'h1B;
                8'd1: current_byte = 8'h40;
                // Clear display
                8'd2: current_byte = 8'h0C;
                // Real-time bit image display command
                8'd3: current_byte = 8'h1F;
                8'd4: current_byte = 8'h28;
                8'd5: current_byte = 8'h66;
                8'd6: current_byte = 8'h11;
                8'd7: current_byte = 8'h08;  // xL = 8
                8'd8: current_byte = 8'h00;  // xH = 0
                8'd9: current_byte = 8'h01;  // yL = 1 (8 dots)
                8'd10: current_byte = 8'h00; // yH = 0
                8'd11: current_byte = 8'h01; // g = 1
                // Diagonal pattern data (D7=top)
                8'd12: current_byte = 8'h80;
                8'd13: current_byte = 8'h40;
                8'd14: current_byte = 8'h20;
                8'd15: current_byte = 8'h10;
                8'd16: current_byte = 8'h08;
                8'd17: current_byte = 8'h04;
                8'd18: current_byte = 8'h02;
                8'd19: current_byte = 8'h01;
                default: current_byte = 8'h00;
            endcase
        end
    end
    
    always @(posedge clk) begin
        case (state)
            STATE_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_idx <= 8'd0;
                leds <= 6'b000001;
                delay_counter <= 20'd0;
                // Wait 100ms at startup
                if (counter < 24'd2700000) counter <= counter + 1;
                else begin counter <= 24'd0; state <= STATE_WAIT_RDY; end
            end
            STATE_WAIT_RDY: begin
                wr_n <= 1'b1;
                leds <= 6'b000010;
                // Wait for READY signal or timeout
                if (ready == 1'b1) begin
                    delay_counter <= 20'd0;
                    state <= STATE_SETUP;
                end else if (delay_counter < 20'd270000) begin // 10ms timeout
                    delay_counter <= delay_counter + 1;
                end else begin
                    delay_counter <= 20'd0;
                    state <= STATE_SETUP;
                end
            end
            STATE_SETUP: begin
                data_bus <= current_byte;
                wr_n <= 1'b1;
                wr_timer <= 8'd0;
                leds <= 6'b000100;
                state <= STATE_PULSE_WR;
            end
            STATE_PULSE_WR: begin
                wr_n <= 1'b0;
                leds <= 6'b001000;
                // ~2us write pulse
                if (wr_timer < 8'd54) wr_timer <= wr_timer + 1;
                else begin wr_timer <= 8'd0; state <= STATE_HOLD; end
            end
            STATE_HOLD: begin
                wr_n <= 1'b1;
                leds <= 6'b010000;
                if (wr_timer < 8'd54) wr_timer <= wr_timer + 1;
                else state <= STATE_NEXT;
            end
            STATE_NEXT: begin
                if (byte_idx < NUM_BYTES - 1) begin
                    byte_idx <= byte_idx + 1;
                    state <= STATE_WAIT_RDY;
                end else state <= STATE_DONE;
            end
            STATE_DONE: begin
                wr_n <= 1'b1;
                leds[4:0] <= 5'b00000;
                leds[5] <= counter[23];
                counter <= counter + 1;
            end
            default: state <= STATE_INIT;
        endcase
    end
    
    initial begin
        state = STATE_INIT;
        counter = 24'd0;
        delay_counter = 20'd0;
        wr_timer = 8'd0;
        byte_idx = 8'd0;
        wr_n = 1'b1;
        data_bus = 8'd0;
        leds = 6'd0;
    end
endmodule
