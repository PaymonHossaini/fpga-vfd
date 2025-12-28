// VFD Graphics Test v49 - Bit verification with working pattern
// Draw dots at x positions to test each data bit

module vfd_graphics_v49 (
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
    reg [23:0] delay_counter;
    reg [7:0] byte_idx;
    
    // 64 nulls + ESC @(2) + CLR(1) + 8 dots × 9 bytes = 139 bytes
    localparam NUM_BYTES = 8'd139;
    localparam NUM_NULLS = 8'd64;
    
    localparam DELAY_SHORT = 24'd27000;    // 1ms between bytes
    localparam DELAY_LONG  = 24'd810000;   // 30ms after init/clear
    localparam SETUP_TIME  = 8'd27;        // ~1us data setup
    localparam PULSE_TIME  = 8'd54;        // ~2us WR pulse
    localparam HOLD_TIME   = 8'd27;        // ~1us data hold
    
    reg [7:0] current_byte;
    reg [23:0] post_delay;
    
    // Combinational logic for current byte and delay
    always @(*) begin
        if (byte_idx < NUM_NULLS) begin
            current_byte = 8'h00;
            post_delay = DELAY_SHORT;
        end else begin
            case (byte_idx - NUM_NULLS)
                // Initialize display: ESC @
                8'd0: begin current_byte = 8'h1B; post_delay = DELAY_SHORT; end
                8'd1: begin current_byte = 8'h40; post_delay = DELAY_LONG; end
                
                // Clear screen
                8'd2: begin current_byte = 8'h0C; post_delay = DELAY_LONG; end
                
                // Dot at x=1 (bit 0), y=64
                8'd3:  begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd4:  begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd5:  begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd6:  begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd7:  begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd8:  begin current_byte = 8'h01; post_delay = DELAY_SHORT; end  // x=1
                8'd9:  begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd10: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end  // y=64
                8'd11: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot at x=2 (bit 1), y=64
                8'd12: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd13: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd14: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd15: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd16: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd17: begin current_byte = 8'h02; post_delay = DELAY_SHORT; end  // x=2
                8'd18: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd19: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end
                8'd20: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot at x=4 (bit 2), y=64
                8'd21: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd22: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd23: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd24: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd25: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd26: begin current_byte = 8'h04; post_delay = DELAY_SHORT; end  // x=4
                8'd27: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd28: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end
                8'd29: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot at x=8 (bit 3), y=64
                8'd30: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd31: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd32: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd33: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd34: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd35: begin current_byte = 8'h08; post_delay = DELAY_SHORT; end  // x=8
                8'd36: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd37: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end
                8'd38: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot at x=16 (bit 4), y=64
                8'd39: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd40: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd41: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd42: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd43: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd44: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end  // x=16
                8'd45: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd46: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end
                8'd47: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot at x=32 (bit 5), y=64
                8'd48: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd49: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd50: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd51: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd52: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd53: begin current_byte = 8'h20; post_delay = DELAY_SHORT; end  // x=32
                8'd54: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd55: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end
                8'd56: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot at x=64 (bit 6), y=64
                8'd57: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd58: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd59: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd60: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd61: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd62: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end  // x=64
                8'd63: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd64: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end
                8'd65: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot at x=128 (bit 7), y=64
                8'd66: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd67: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd68: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd69: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd70: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd71: begin current_byte = 8'h80; post_delay = DELAY_SHORT; end  // x=128
                8'd72: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd73: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end
                8'd74: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                default: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
            endcase
        end
    end

    always @(posedge clk) begin
        leds[3:0] <= state;
        leds[4] <= ready;
        leds[5] <= (state == STATE_DONE);
        
        case (state)
            STATE_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_idx <= 0;
                delay_counter <= DELAY_LONG;
                state <= STATE_WAIT_RDY;
            end
            
            STATE_WAIT_RDY: begin
                if (delay_counter > 0)
                    delay_counter <= delay_counter - 1;
                else if (ready)
                    state <= STATE_SETUP;
            end
            
            STATE_SETUP: begin
                data_bus <= current_byte;
                wr_n <= 1'b1;
                delay_counter <= SETUP_TIME;
                state <= STATE_SETUP_HOLD;
            end
            
            STATE_SETUP_HOLD: begin
                if (delay_counter > 0)
                    delay_counter <= delay_counter - 1;
                else begin
                    state <= STATE_PULSE_WR;
                    delay_counter <= PULSE_TIME;
                end
            end
            
            STATE_PULSE_WR: begin
                wr_n <= 1'b0;
                if (delay_counter > 0)
                    delay_counter <= delay_counter - 1;
                else begin
                    state <= STATE_HOLD;
                    delay_counter <= HOLD_TIME;
                end
            end
            
            STATE_HOLD: begin
                wr_n <= 1'b1;
                if (delay_counter > 0)
                    delay_counter <= delay_counter - 1;
                else begin
                    state <= STATE_POST_DELAY;
                    delay_counter <= post_delay;
                end
            end
            
            STATE_POST_DELAY: begin
                if (delay_counter > 0)
                    delay_counter <= delay_counter - 1;
                else
                    state <= STATE_NEXT;
            end
            
            STATE_NEXT: begin
                if (byte_idx < NUM_BYTES - 1) begin
                    byte_idx <= byte_idx + 1;
                    state <= STATE_WAIT_RDY;
                    delay_counter <= 0;
                end else
                    state <= STATE_DONE;
            end
            
            STATE_DONE: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
            end
            
            default: state <= STATE_INIT;
        endcase
    end

endmodule
