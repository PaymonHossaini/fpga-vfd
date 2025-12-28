// VFD Graphics Test v21 - Non-interleaved: all TOP bytes, then all BOT bytes
// Based on cursor diagram: X goes right, Y goes down
// Bytes 0-15 = TOP row (rows 0-7) for columns 0-15
// Bytes 16-31 = BOTTOM row (rows 8-15) for columns 0-15

module vfd_graphics_v21 (
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
    reg [7:0] wr_timer;
    reg [5:0] byte_idx;
    
    localparam NUM_BYTES = 6'd42;
    
    reg [7:0] current_byte;
    
    always @(*) begin
        case (byte_idx)
            6'd0: current_byte = 8'h0C;
            6'd1: current_byte = 8'h1F;
            6'd2: current_byte = 8'h28;
            6'd3: current_byte = 8'h66;
            6'd4: current_byte = 8'h11;
            6'd5: current_byte = 8'h10;
            6'd6: current_byte = 8'h00;
            6'd7: current_byte = 8'h02;
            6'd8: current_byte = 8'h00;
            6'd9: current_byte = 8'h01;
            // TOP ROW (rows 0-7) for cols 0-15. D7=row0
            6'd10: current_byte = 8'hFF;  // col 0 left edge
            6'd11: current_byte = 8'h80;  // col 1 top pixel
            6'd12: current_byte = 8'h80;
            6'd13: current_byte = 8'h80;
            6'd14: current_byte = 8'h80;
            6'd15: current_byte = 8'h80;
            6'd16: current_byte = 8'h80;
            6'd17: current_byte = 8'h80;
            6'd18: current_byte = 8'h80;
            6'd19: current_byte = 8'h80;
            6'd20: current_byte = 8'h80;
            6'd21: current_byte = 8'h80;
            6'd22: current_byte = 8'h80;
            6'd23: current_byte = 8'h80;
            6'd24: current_byte = 8'h80;
            6'd25: current_byte = 8'hFF;  // col 15 right edge
            // BOTTOM ROW (rows 8-15) for cols 0-15. D0=row15
            6'd26: current_byte = 8'hFF;  // col 0 left edge
            6'd27: current_byte = 8'h01;  // col 1 bottom pixel
            6'd28: current_byte = 8'h01;
            6'd29: current_byte = 8'h01;
            6'd30: current_byte = 8'h01;
            6'd31: current_byte = 8'h01;
            6'd32: current_byte = 8'h01;
            6'd33: current_byte = 8'h01;
            6'd34: current_byte = 8'h01;
            6'd35: current_byte = 8'h01;
            6'd36: current_byte = 8'h01;
            6'd37: current_byte = 8'h01;
            6'd38: current_byte = 8'h01;
            6'd39: current_byte = 8'h01;
            6'd40: current_byte = 8'h01;
            6'd41: current_byte = 8'hFF;  // col 15 right edge
            default: current_byte = 8'h00;
        endcase
    end
    
    always @(posedge clk) begin
        case (state)
            STATE_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_idx <= 6'd0;
                leds <= 6'b000001;
                if (counter < 24'd2700000) counter <= counter + 1;
                else begin counter <= 24'd0; state <= STATE_WAIT_RDY; end
            end
            STATE_WAIT_RDY: begin
                wr_n <= 1'b1;
                leds <= 6'b000010;
                if (ready || counter > 24'd50000) begin state <= STATE_SETUP; counter <= 24'd0; end
                else counter <= counter + 1;
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
                if (wr_timer < 8'd20) wr_timer <= wr_timer + 1;
                else begin wr_timer <= 8'd0; state <= STATE_HOLD; end
            end
            STATE_HOLD: begin
                wr_n <= 1'b1;
                leds <= 6'b010000;
                if (wr_timer < 8'd20) wr_timer <= wr_timer + 1;
                else state <= STATE_NEXT;
            end
            STATE_NEXT: begin
                if (byte_idx < NUM_BYTES - 1) begin byte_idx <= byte_idx + 1; state <= STATE_WAIT_RDY; end
                else state <= STATE_DONE;
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
        state <= STATE_INIT;
        counter <= 24'd0;
        wr_timer <= 8'd0;
        byte_idx <= 6'd0;
        wr_n <= 1'b1;
        data_bus <= 8'd0;
        leds <= 6'd0;
    end
endmodule
