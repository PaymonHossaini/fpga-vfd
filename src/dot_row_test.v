// VFD Single Dot Test - Testing y=6, y=7, y=8 to find broken rows
// Uses command: 1F 28 64 10 01 xL xH yL yH

module vfd_image_display (
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
    reg [15:0] wr_timer;
    reg [7:0] byte_idx;
    
    localparam DELAY_SHORT = 24'd27000;   // ~1ms
    localparam DELAY_LONG  = 24'd810000;  // ~30ms
    localparam SETUP_TIME  = 16'd27;      // ~1us
    localparam PULSE_TIME  = 16'd54;      // ~2us
    localparam HOLD_TIME   = 16'd27;      // ~1us
    
    localparam NUM_BYTES = 8'd42;
    
    reg [7:0] current_byte;
    reg [23:0] post_delay;
    
    always @(*) begin
        case (byte_idx)
            // Init and clear
            8'd0: begin current_byte = 8'h1B; post_delay = DELAY_SHORT; end  // ESC
            8'd1: begin current_byte = 8'h40; post_delay = DELAY_LONG; end   // @ (init)
            8'd2: begin current_byte = 8'h0C; post_delay = DELAY_LONG; end   // CLR
            
            // Dot at x=10, y=6 (bit 6 = 0x40)
            8'd3:  begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd4:  begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd5:  begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd6:  begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd7:  begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
            8'd8:  begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end  // x=10
            8'd9:  begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd10: begin current_byte = 8'h06; post_delay = DELAY_SHORT; end  // y=6
            8'd11: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
            // Dot at x=20, y=7 (bit 7 = 0x80)
            8'd12: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd13: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd14: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd15: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd16: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
            8'd17: begin current_byte = 8'h14; post_delay = DELAY_SHORT; end  // x=20
            8'd18: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd19: begin current_byte = 8'h07; post_delay = DELAY_SHORT; end  // y=7
            8'd20: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
            // Dot at x=30, y=8 (bit 0 of next byte = 0x01)
            8'd21: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd22: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd23: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd24: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd25: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
            8'd26: begin current_byte = 8'h1E; post_delay = DELAY_SHORT; end  // x=30
            8'd27: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd28: begin current_byte = 8'h08; post_delay = DELAY_SHORT; end  // y=8
            8'd29: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
            // Dot at x=40, y=9 (bit 1 = 0x02) - for reference
            8'd30: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd31: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd32: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd33: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd34: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
            8'd35: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end  // x=40
            8'd36: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd37: begin current_byte = 8'h09; post_delay = DELAY_SHORT; end  // y=9
            8'd38: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
            // Dot at x=50, y=15 (bit 7 = 0x80) - should be visible
            8'd39: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd40: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd41: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd42: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd43: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
            8'd44: begin current_byte = 8'h32; post_delay = DELAY_SHORT; end  // x=50
            8'd45: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd46: begin current_byte = 8'h0F; post_delay = DELAY_SHORT; end  // y=15
            8'd47: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
            default: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
        endcase
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
                wr_timer <= 16'd0;
                leds <= 6'b000100;
                state <= STATE_PULSE_WR;
            end
            
            STATE_PULSE_WR: begin
                wr_timer <= wr_timer + 1;
                if (wr_timer < SETUP_TIME) begin
                    wr_n <= 1'b1;
                end else if (wr_timer < SETUP_TIME + PULSE_TIME) begin
                    wr_n <= 1'b0;
                end else begin
                    wr_n <= 1'b1;
                    state <= STATE_HOLD;
                    wr_timer <= 16'd0;
                end
            end
            
            STATE_HOLD: begin
                wr_timer <= wr_timer + 1;
                if (wr_timer >= HOLD_TIME) begin
                    delay_counter <= 24'd0;
                    state <= STATE_POST_DELAY;
                end
            end
            
            STATE_POST_DELAY: begin
                leds <= 6'b001000;
                delay_counter <= delay_counter + 1;
                if (delay_counter >= post_delay) begin
                    state <= STATE_NEXT;
                end
            end
            
            STATE_NEXT: begin
                leds <= 6'b010000;
                if (byte_idx < NUM_BYTES) begin
                    byte_idx <= byte_idx + 1;
                    state <= STATE_WAIT_RDY;
                end else begin
                    state <= STATE_DONE;
                end
            end
            
            STATE_DONE: begin
                leds <= 6'b100000;
                wr_n <= 1'b1;
            end
        endcase
    end

endmodule
