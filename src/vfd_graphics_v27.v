// VFD Graphics Test v27 - 16x16 Box Outline
// Based on confirmed: D7=top, column-by-column ordering

module vfd_graphics_v27 (
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
    reg [7:0] byte_idx;
    
    // 64 nulls + Init(2) + Clear(1) + Cmd(9) + 32 data bytes = 108
    localparam NUM_BYTES = 8'd108;
    localparam NUM_NULLS = 8'd64;
    
    reg [7:0] current_byte;
    
    always @(*) begin
        if (byte_idx < NUM_NULLS) begin
            current_byte = 8'h00;
        end else begin
            case (byte_idx - NUM_NULLS)
                // Initialize display
                8'd0: current_byte = 8'h1B;
                8'd1: current_byte = 8'h40;
                // Clear display
                8'd2: current_byte = 8'h0C;
                // Real-time bit image: 1F 28 66 11 xL xH yL yH g
                8'd3: current_byte = 8'h1F;
                8'd4: current_byte = 8'h28;
                8'd5: current_byte = 8'h66;
                8'd6: current_byte = 8'h11;
                8'd7: current_byte = 8'h10;  // xL = 16
                8'd8: current_byte = 8'h00;  // xH = 0
                8'd9: current_byte = 8'h02;  // yL = 2 (16 dots)
                8'd10: current_byte = 8'h00; // yH = 0
                8'd11: current_byte = 8'h01; // g = 1
                
                // 16x16 box outline: 32 bytes (16 cols × 2 bytes each)
                // Column 0 (left edge): full vertical
                8'd12: current_byte = 8'hFF;  // top 8 rows
                8'd13: current_byte = 8'hFF;  // bottom 8 rows
                // Columns 1-14: only top and bottom edges
                8'd14: current_byte = 8'h80;  // col 1 top (D7=top row)
                8'd15: current_byte = 8'h01;  // col 1 bot (D0=bottom row)
                8'd16: current_byte = 8'h80;  // col 2
                8'd17: current_byte = 8'h01;
                8'd18: current_byte = 8'h80;  // col 3
                8'd19: current_byte = 8'h01;
                8'd20: current_byte = 8'h80;  // col 4
                8'd21: current_byte = 8'h01;
                8'd22: current_byte = 8'h80;  // col 5
                8'd23: current_byte = 8'h01;
                8'd24: current_byte = 8'h80;  // col 6
                8'd25: current_byte = 8'h01;
                8'd26: current_byte = 8'h80;  // col 7
                8'd27: current_byte = 8'h01;
                8'd28: current_byte = 8'h80;  // col 8
                8'd29: current_byte = 8'h01;
                8'd30: current_byte = 8'h80;  // col 9
                8'd31: current_byte = 8'h01;
                8'd32: current_byte = 8'h80;  // col 10
                8'd33: current_byte = 8'h01;
                8'd34: current_byte = 8'h80;  // col 11
                8'd35: current_byte = 8'h01;
                8'd36: current_byte = 8'h80;  // col 12
                8'd37: current_byte = 8'h01;
                8'd38: current_byte = 8'h80;  // col 13
                8'd39: current_byte = 8'h01;
                8'd40: current_byte = 8'h80;  // col 14
                8'd41: current_byte = 8'h01;
                // Column 15 (right edge): full vertical
                8'd42: current_byte = 8'hFF;
                8'd43: current_byte = 8'hFF;
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
                if (counter < 24'd2700000) counter <= counter + 1;
                else begin counter <= 24'd0; state <= STATE_WAIT_RDY; end
            end
            STATE_WAIT_RDY: begin
                wr_n <= 1'b1;
                leds <= 6'b000010;
                if (ready == 1'b1) begin
                    delay_counter <= 20'd0;
                    state <= STATE_SETUP;
                end else if (delay_counter < 20'd270000) begin
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
