// VFD Graphics Test v44 - Bit verification using dots
// Uses v35 timing which works consistently
// Draws dots at positions that verify each data bit

module vfd_graphics_v44 (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    localparam STATE_INIT       = 4'd0;
    localparam STATE_WAIT_RDY   = 4'd1;
    localparam STATE_SETUP      = 4'd2;
    localparam STATE_SETUP_HOLD = 4'd3;
    localparam STATE_PULSE_WR   = 4'd4;
    localparam STATE_HOLD       = 4'd5;
    localparam STATE_POST_DELAY = 4'd6;
    localparam STATE_NEXT       = 4'd7;
    localparam STATE_DONE       = 4'd8;
    
    reg [3:0] state;
    reg [23:0] counter;
    reg [23:0] delay_counter;
    reg [7:0] wr_timer;
    reg [7:0] byte_idx;
    
    // Init(2) + Clear(1) + 8 dots × 9 bytes = 75 bytes
    localparam NUM_BYTES = 8'd75;
    
    localparam DELAY_SHORT = 24'd27000;    // 1ms
    localparam DELAY_LONG  = 24'd810000;   // 30ms
    localparam SETUP_TIME  = 8'd27;        // ~1us data setup
    localparam PULSE_TIME  = 8'd54;        // ~2us WR pulse
    localparam HOLD_TIME   = 8'd27;        // ~1us hold
    
    reg [7:0] current_byte;
    reg [23:0] post_delay;
    
    always @(*) begin
        case (byte_idx)
            // Initialize display: ESC @
            8'd0: begin current_byte = 8'h1B; post_delay = DELAY_SHORT; end
            8'd1: begin current_byte = 8'h40; post_delay = DELAY_LONG; end
            
            // Clear screen
            8'd2: begin current_byte = 8'h0C; post_delay = DELAY_LONG; end
            
            // Dot 1 at x=1 (bit 0 test)
            8'd3:  begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd4:  begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd5:  begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd6:  begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd7:  begin current_byte = 8'h01; post_delay = DELAY_SHORT; end  // pen=1
            8'd8:  begin current_byte = 8'h01; post_delay = DELAY_SHORT; end  // x=1
            8'd9:  begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd10: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end  // y=10
            8'd11: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
            // Dot 2 at x=2 (bit 1 test)
            8'd12: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd13: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd14: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd15: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd16: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
            8'd17: begin current_byte = 8'h02; post_delay = DELAY_SHORT; end  // x=2
            8'd18: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd19: begin current_byte = 8'h14; post_delay = DELAY_SHORT; end  // y=20
            8'd20: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
            // Dot 3 at x=4 (bit 2 test)
            8'd21: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd22: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd23: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd24: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd25: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
            8'd26: begin current_byte = 8'h04; post_delay = DELAY_SHORT; end  // x=4
            8'd27: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd28: begin current_byte = 8'h1E; post_delay = DELAY_SHORT; end  // y=30
            8'd29: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
            // Dot 4 at x=8 (bit 3 test)
            8'd30: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd31: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd32: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd33: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd34: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
            8'd35: begin current_byte = 8'h08; post_delay = DELAY_SHORT; end  // x=8
            8'd36: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd37: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end  // y=40
            8'd38: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
            // Dot 5 at x=16 (bit 4 test)
            8'd39: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd40: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd41: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd42: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd43: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
            8'd44: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end  // x=16
            8'd45: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd46: begin current_byte = 8'h32; post_delay = DELAY_SHORT; end  // y=50
            8'd47: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
            // Dot 6 at x=32 (bit 5 test)
            8'd48: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd49: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd50: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd51: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd52: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
            8'd53: begin current_byte = 8'h20; post_delay = DELAY_SHORT; end  // x=32
            8'd54: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd55: begin current_byte = 8'h3C; post_delay = DELAY_SHORT; end  // y=60
            8'd56: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
            // Dot 7 at x=64 (bit 6 test)
            8'd57: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd58: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd59: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd60: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd61: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
            8'd62: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end  // x=64
            8'd63: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd64: begin current_byte = 8'h46; post_delay = DELAY_SHORT; end  // y=70
            8'd65: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
            // Dot 8 at x=128 (bit 7 test)
            8'd66: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
            8'd67: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
            8'd68: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
            8'd69: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
            8'd70: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
            8'd71: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end  // x=128
            8'd72: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            8'd73: begin current_byte = 8'h50; post_delay = DELAY_SHORT; end  // y=80
            8'd74: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
            
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
                // 100ms startup delay
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
                state <= STATE_SETUP_HOLD;
            end
            
            STATE_SETUP_HOLD: begin
                wr_n <= 1'b1;
                if (wr_timer < SETUP_TIME) begin
                    wr_timer <= wr_timer + 1;
                end else begin
                    wr_timer <= 8'd0;
                    state <= STATE_PULSE_WR;
                end
            end
            
            STATE_PULSE_WR: begin
                wr_n <= 1'b0;
                leds <= 6'b001000;
                if (wr_timer < PULSE_TIME) begin
                    wr_timer <= wr_timer + 1;
                end else begin
                    wr_timer <= 8'd0;
                    state <= STATE_HOLD;
                end
            end
            
            STATE_HOLD: begin
                wr_n <= 1'b1;
                leds <= 6'b010000;
                if (wr_timer < HOLD_TIME) begin
                    wr_timer <= wr_timer + 1;
                end else begin
                    delay_counter <= 24'd0;
                    state <= STATE_POST_DELAY;
                end
            end
            
            STATE_POST_DELAY: begin
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
                end else begin
                    state <= STATE_DONE;
                end
            end
            
            STATE_DONE: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
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
