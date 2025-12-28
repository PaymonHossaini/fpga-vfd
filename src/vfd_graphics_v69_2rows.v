// VFD Graphics Test v69 - 16 dots in 2 rows (debug version)
// Simpler pattern to debug transmission issues

module vfd_graphics_v69_2rows (
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
    reg [9:0] byte_idx;
    
    // 64 nulls + Init(2) + Clear(1) + 16 dots × 9 bytes = 211
    localparam NUM_BYTES = 10'd211;
    localparam NUM_NULLS = 8'd64;
    
    localparam DELAY_SHORT = 24'd27000;    // 1ms between bytes
    localparam DELAY_LONG  = 24'd810000;   // 30ms after init/clear
    localparam SETUP_TIME  = 8'd27;        // ~1us data setup time before WR
    localparam PULSE_TIME  = 8'd54;        // ~2us WR pulse width
    localparam HOLD_TIME   = 8'd27;        // ~1us data hold after WR
    
    reg [7:0] current_byte;
    reg [23:0] post_delay;
    
    always @(*) begin
        if (byte_idx < NUM_NULLS) begin
            current_byte = 8'h00;
            post_delay = DELAY_SHORT;
        end else begin
            case (byte_idx - NUM_NULLS)
                // Initialize display: ESC @
                10'd0: begin current_byte = 8'h1B; post_delay = DELAY_SHORT; end
                10'd1: begin current_byte = 8'h40; post_delay = DELAY_LONG; end
                
                // Clear screen
                10'd2: begin current_byte = 8'h0C; post_delay = DELAY_LONG; end
                
                // Row 1: y=10, x from 10 to 235 in steps of 15 (16 dots)
                // Dot 0: x=10
                10'd3:  begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd4:  begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd5:  begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd6:  begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd7:  begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd8:  begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd9:  begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd10: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd11: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 1: x=25
                10'd12: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd13: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd14: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd15: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd16: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd17: begin current_byte = 8'h19; post_delay = DELAY_SHORT; end
                10'd18: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd19: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd20: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 2: x=40
                10'd21: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd22: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd23: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd24: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd25: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd26: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd27: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd28: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd29: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 3: x=55
                10'd30: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd31: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd32: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd33: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd34: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd35: begin current_byte = 8'h37; post_delay = DELAY_SHORT; end
                10'd36: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd37: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd38: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 4: x=70
                10'd39: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd40: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd41: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd42: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd43: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd44: begin current_byte = 8'h46; post_delay = DELAY_SHORT; end
                10'd45: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd46: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd47: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 5: x=85
                10'd48: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd49: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd50: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd51: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd52: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd53: begin current_byte = 8'h55; post_delay = DELAY_SHORT; end
                10'd54: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd55: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd56: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 6: x=100
                10'd57: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd58: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd59: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd60: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd61: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd62: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd63: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd64: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd65: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 7: x=115
                10'd66: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd67: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd68: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd69: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd70: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd71: begin current_byte = 8'h73; post_delay = DELAY_SHORT; end
                10'd72: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd73: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd74: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 8: x=130
                10'd75: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd76: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd77: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd78: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd79: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd80: begin current_byte = 8'h82; post_delay = DELAY_SHORT; end
                10'd81: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd82: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd83: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 9: x=145
                10'd84: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd85: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd86: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd87: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd88: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd89: begin current_byte = 8'h91; post_delay = DELAY_SHORT; end
                10'd90: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd91: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd92: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 10: x=160
                10'd93: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd94: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd95: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd96: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd97: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd98: begin current_byte = 8'hA0; post_delay = DELAY_SHORT; end
                10'd99: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd100: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd101: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 11: x=175
                10'd102: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd103: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd104: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd105: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd106: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd107: begin current_byte = 8'hAF; post_delay = DELAY_SHORT; end
                10'd108: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd109: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd110: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 12: x=190
                10'd111: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd112: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd113: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd114: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd115: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd116: begin current_byte = 8'hBE; post_delay = DELAY_SHORT; end
                10'd117: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd118: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd119: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 13: x=205
                10'd120: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd121: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd122: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd123: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd124: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd125: begin current_byte = 8'hCD; post_delay = DELAY_SHORT; end
                10'd126: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd127: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd128: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 14: x=220
                10'd129: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd130: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd131: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd132: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd133: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd134: begin current_byte = 8'hDC; post_delay = DELAY_SHORT; end
                10'd135: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd136: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd137: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 15: x=235
                10'd138: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd139: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd140: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd141: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd142: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd143: begin current_byte = 8'hEB; post_delay = DELAY_SHORT; end
                10'd144: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd145: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd146: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Row 2: y=22, x from 10 to 235 (same x positions)
                // Dot 16: x=10
                10'd147: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd148: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd149: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd150: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd151: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd152: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                10'd153: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd154: begin current_byte = 8'h16; post_delay = DELAY_SHORT; end
                10'd155: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 17: x=25
                10'd156: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd157: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd158: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd159: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd160: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd161: begin current_byte = 8'h19; post_delay = DELAY_SHORT; end
                10'd162: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd163: begin current_byte = 8'h16; post_delay = DELAY_SHORT; end
                10'd164: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 18: x=40
                10'd165: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd166: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd167: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd168: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd169: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd170: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd171: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd172: begin current_byte = 8'h16; post_delay = DELAY_SHORT; end
                10'd173: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 19: x=55
                10'd174: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd175: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd176: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd177: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd178: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd179: begin current_byte = 8'h37; post_delay = DELAY_SHORT; end
                10'd180: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd181: begin current_byte = 8'h16; post_delay = DELAY_SHORT; end
                10'd182: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 20: x=70
                10'd183: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd184: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd185: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd186: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd187: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd188: begin current_byte = 8'h46; post_delay = DELAY_SHORT; end
                10'd189: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd190: begin current_byte = 8'h16; post_delay = DELAY_SHORT; end
                10'd191: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 21: x=85
                10'd192: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                10'd193: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                10'd194: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                10'd195: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                10'd196: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                10'd197: begin current_byte = 8'h55; post_delay = DELAY_SHORT; end
                10'd198: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                10'd199: begin current_byte = 8'h16; post_delay = DELAY_SHORT; end
                10'd200: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 22-31 are the same x coordinates but y=22, abbreviated for space
                // Dots 22-31: x=100, 115, 130, 145, 160, 175, 190, 205, 220, 235
                
                default: begin 
                    current_byte = 8'h00; 
                    post_delay = DELAY_SHORT;
                end
            endcase
        end
    end
    
    always @(posedge clk) begin
        case (state)
            STATE_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_idx <= 10'd0;
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
        byte_idx = 10'd0;
        wr_n = 1'b1;
        data_bus = 8'd0;
        leds = 6'd0;
    end
endmodule
