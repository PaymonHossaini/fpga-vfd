// VFD Graphics Test v24 - 15ms timing per the 256x128 spec
// 27MHz * 0.015s = 405000 cycles per 15ms

module vfd_graphics_v24 (
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
    reg [5:0] byte_idx;
    
    // 8x8 diagonal
    localparam NUM_BYTES = 6'd18;
    
    // 15ms at 27MHz = 405000 cycles
    localparam DELAY_15MS = 20'd405000;
    
    reg [7:0] current_byte;
    
    always @(*) begin
        case (byte_idx)
            6'd0: current_byte = 8'h0C;  // Clear
            6'd1: current_byte = 8'h1F;
            6'd2: current_byte = 8'h28;
            6'd3: current_byte = 8'h66;
            6'd4: current_byte = 8'h11;
            6'd5: current_byte = 8'h08;  // xL = 8
            6'd6: current_byte = 8'h00;  // xH = 0
            6'd7: current_byte = 8'h01;  // yL = 1
            6'd8: current_byte = 8'h00;  // yH = 0
            6'd9: current_byte = 8'h01;  // g = 1
            // Diagonal: D7=top
            6'd10: current_byte = 8'h80;
            6'd11: current_byte = 8'h40;
            6'd12: current_byte = 8'h20;
            6'd13: current_byte = 8'h10;
            6'd14: current_byte = 8'h08;
            6'd15: current_byte = 8'h04;
            6'd16: current_byte = 8'h02;
            6'd17: current_byte = 8'h01;
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
                delay_counter <= 20'd0;
                // Wait 100ms at startup (about 7x 15ms)
                if (counter < 24'd2700000) counter <= counter + 1;
                else begin counter <= 24'd0; state <= STATE_WAIT_RDY; end
            end
            STATE_WAIT_RDY: begin
                wr_n <= 1'b1;
                leds <= 6'b000010;
                // Wait 15ms before each byte
                if (delay_counter < DELAY_15MS) begin
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
                // ~2us write pulse (54 cycles)
                if (wr_timer < 8'd54) wr_timer <= wr_timer + 1;
                else begin wr_timer <= 8'd0; state <= STATE_HOLD; end
            end
            STATE_HOLD: begin
                wr_n <= 1'b1;
                leds <= 6'b010000;
                // Short hold after write
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
        state <= STATE_INIT;
        counter <= 24'd0;
        delay_counter <= 20'd0;
        wr_timer <= 8'd0;
        byte_idx <= 6'd0;
        wr_n <= 1'b1;
        data_bus <= 8'd0;
        leds <= 6'd0;
    end
endmodule
