// VFD Graphics Test v28 - Add delays after init/clear commands

module vfd_graphics_v28 (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    localparam STATE_INIT       = 4'd0;
    localparam STATE_WAIT_RDY   = 4'd1;
    localparam STATE_SETUP      = 4'd2;
    localparam STATE_PULSE_WR   = 4'd3;
    localparam STATE_HOLD       = 4'd4;
    localparam STATE_POST_DELAY = 4'd5;
    localparam STATE_NEXT       = 4'd6;
    localparam STATE_DONE       = 4'd7;
    
    reg [3:0] state;
    reg [23:0] counter;
    reg [23:0] delay_counter;
    reg [7:0] wr_timer;
    reg [7:0] byte_idx;
    
    // 64 nulls + Init(2) + Clear(1) + Cmd(9) + 32 data bytes = 108
    localparam NUM_BYTES = 8'd108;
    localparam NUM_NULLS = 8'd64;
    
    // Delays
    localparam DELAY_SHORT = 24'd27000;    // 1ms
    localparam DELAY_LONG  = 24'd810000;   // 30ms for init/clear
    
    reg [7:0] current_byte;
    reg [23:0] post_delay;
    
    always @(*) begin
        if (byte_idx < NUM_NULLS) begin
            current_byte = 8'h00;
            post_delay = DELAY_SHORT;
        end else begin
            case (byte_idx - NUM_NULLS)
                // Initialize display - needs long delay after
                8'd0: begin current_byte = 8'h1B; post_delay = DELAY_SHORT; end
                8'd1: begin current_byte = 8'h40; post_delay = DELAY_LONG; end
                // Clear display - needs long delay after
                8'd2: begin current_byte = 8'h0C; post_delay = DELAY_LONG; end
                // Real-time bit image command
                8'd3: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd4: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd5: begin current_byte = 8'h66; post_delay = DELAY_SHORT; end
                8'd6: begin current_byte = 8'h11; post_delay = DELAY_SHORT; end
                8'd7: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end  // xL = 16
                8'd8: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end  // xH
                8'd9: begin current_byte = 8'h02; post_delay = DELAY_SHORT; end  // yL = 2
                8'd10: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end // yH
                8'd11: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end // g = 1
                
                // 16x16 box outline: 32 bytes
                // Column 0 (left edge): full vertical
                8'd12: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd13: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                // Columns 1-14: only top and bottom edges
                8'd14: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd15: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd16: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd17: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd18: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd19: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd20: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd21: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd22: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd23: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd24: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd25: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd26: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd27: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd28: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd29: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd30: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd31: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd32: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd33: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd34: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd35: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd36: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd37: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd38: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd39: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd40: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end
                8'd41: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                // Column 15 (right edge): full vertical
                8'd42: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd43: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                default: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
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
                delay_counter <= 24'd0;
                if (counter < 24'd2700000) counter <= counter + 1;
                else begin counter <= 24'd0; state <= STATE_WAIT_RDY; end
            end
            STATE_WAIT_RDY: begin
                wr_n <= 1'b1;
                leds <= 6'b000010;
                if (ready == 1'b1) begin
                    delay_counter <= 24'd0;
                    state <= STATE_SETUP;
                end else if (delay_counter < 24'd270000) begin
                    delay_counter <= delay_counter + 1;
                end else begin
                    delay_counter <= 24'd0;
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
                else begin delay_counter <= 24'd0; state <= STATE_POST_DELAY; end
            end
            STATE_POST_DELAY: begin
                // Variable delay after each byte
                if (delay_counter < post_delay) begin
                    delay_counter <= delay_counter + 1;
                end else begin
                    state <= STATE_NEXT;
                end
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
        delay_counter = 24'd0;
        wr_timer = 8'd0;
        byte_idx = 8'd0;
        wr_n = 1'b1;
        data_bus = 8'd0;
        leds = 6'd0;
    end
endmodule
