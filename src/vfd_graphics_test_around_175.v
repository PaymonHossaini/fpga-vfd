// VFD Graphics Test - Systematic test around x=175 (0xAF)
// Test x values: 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182
// All at different y positions for easy identification

module vfd_graphics_test_around_175 (
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
    
    // 64 nulls + Init(2) + Clear(1) + 15 dots × 9 bytes = 202
    localparam NUM_BYTES = 8'd202;
    localparam NUM_NULLS = 8'd64;
    
    localparam DELAY_SHORT = 24'd27000;    // 1ms between bytes
    localparam DELAY_LONG  = 24'd810000;   // 30ms after init/clear
    localparam SETUP_TIME  = 8'd27;
    localparam PULSE_TIME  = 8'd54;
    localparam HOLD_TIME   = 8'd27;
    
    reg [7:0] current_byte;
    reg [23:0] post_delay;
    
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
                
                // Dot 1: x=168 (0xA8), y=8
                8'd3:  begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd4:  begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd5:  begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd6:  begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd7:  begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd8:  begin current_byte = 8'hA8; post_delay = DELAY_SHORT; end  // 168
                8'd9:  begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd10: begin current_byte = 8'h08; post_delay = DELAY_SHORT; end  // y=8
                8'd11: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 2: x=169 (0xA9), y=16
                8'd12: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd13: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd14: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd15: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd16: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd17: begin current_byte = 8'hA9; post_delay = DELAY_SHORT; end  // 169
                8'd18: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd19: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end  // y=16
                8'd20: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 3: x=170 (0xAA), y=24
                8'd21: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd22: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd23: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd24: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd25: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd26: begin current_byte = 8'hAA; post_delay = DELAY_SHORT; end  // 170
                8'd27: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd28: begin current_byte = 8'h18; post_delay = DELAY_SHORT; end  // y=24
                8'd29: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 4: x=171 (0xAB), y=32
                8'd30: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd31: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd32: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd33: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd34: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd35: begin current_byte = 8'hAB; post_delay = DELAY_SHORT; end  // 171
                8'd36: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd37: begin current_byte = 8'h20; post_delay = DELAY_SHORT; end  // y=32
                8'd38: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 5: x=172 (0xAC), y=40
                8'd39: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd40: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd41: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd42: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd43: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd44: begin current_byte = 8'hAC; post_delay = DELAY_SHORT; end  // 172
                8'd45: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd46: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end  // y=40
                8'd47: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 6: x=173 (0xAD), y=48
                8'd48: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd49: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd50: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd51: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd52: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd53: begin current_byte = 8'hAD; post_delay = DELAY_SHORT; end  // 173
                8'd54: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd55: begin current_byte = 8'h30; post_delay = DELAY_SHORT; end  // y=48
                8'd56: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 7: x=174 (0xAE), y=56
                8'd57: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd58: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd59: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd60: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd61: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd62: begin current_byte = 8'hAE; post_delay = DELAY_SHORT; end  // 174
                8'd63: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd64: begin current_byte = 8'h38; post_delay = DELAY_SHORT; end  // y=56
                8'd65: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 8: x=175 (0xAF), y=64  *** THE PROBLEM VALUE ***
                8'd66: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd67: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd68: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd69: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd70: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd71: begin current_byte = 8'hAF; post_delay = DELAY_SHORT; end  // 175
                8'd72: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd73: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end  // y=64
                8'd74: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 9: x=176 (0xB0), y=72
                8'd75: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd76: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd77: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd78: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd79: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd80: begin current_byte = 8'hB0; post_delay = DELAY_SHORT; end  // 176
                8'd81: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd82: begin current_byte = 8'h48; post_delay = DELAY_SHORT; end  // y=72
                8'd83: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 10: x=177 (0xB1), y=80
                8'd84: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd85: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd86: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd87: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd88: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd89: begin current_byte = 8'hB1; post_delay = DELAY_SHORT; end  // 177
                8'd90: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd91: begin current_byte = 8'h50; post_delay = DELAY_SHORT; end  // y=80
                8'd92: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 11: x=178 (0xB2), y=88
                8'd93: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd94: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd95: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd96: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd97: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd98: begin current_byte = 8'hB2; post_delay = DELAY_SHORT; end  // 178
                8'd99: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd100: begin current_byte = 8'h58; post_delay = DELAY_SHORT; end  // y=88
                8'd101: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 12: x=179 (0xB3), y=96
                8'd102: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd103: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd104: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd105: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd106: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd107: begin current_byte = 8'hB3; post_delay = DELAY_SHORT; end  // 179
                8'd108: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd109: begin current_byte = 8'h60; post_delay = DELAY_SHORT; end  // y=96
                8'd110: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 13: x=180 (0xB4), y=104
                8'd111: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd112: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd113: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd114: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd115: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd116: begin current_byte = 8'hB4; post_delay = DELAY_SHORT; end  // 180
                8'd117: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd118: begin current_byte = 8'h68; post_delay = DELAY_SHORT; end  // y=104
                8'd119: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 14: x=181 (0xB5), y=112
                8'd120: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd121: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd122: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd123: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd124: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd125: begin current_byte = 8'hB5; post_delay = DELAY_SHORT; end  // 181
                8'd126: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd127: begin current_byte = 8'h70; post_delay = DELAY_SHORT; end  // y=112
                8'd128: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 15: x=182 (0xB6), y=120
                8'd129: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd130: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd131: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd132: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd133: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd134: begin current_byte = 8'hB6; post_delay = DELAY_SHORT; end  // 182
                8'd135: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd136: begin current_byte = 8'h78; post_delay = DELAY_SHORT; end  // y=120
                8'd137: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
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
