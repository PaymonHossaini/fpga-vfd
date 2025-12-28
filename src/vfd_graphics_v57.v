// VFD Graphics Test v57 - Test individual bits in x position
// Draw dots at x=1,2,4,8,16,32,64,128 to test each bit
// Based on working v48 structure

module vfd_graphics_v57 (
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
    
    // 64 nulls + ESC @(2) + CLR(1) + 3 dots × 9 bytes = 94 bytes
    // Testing just 3 dots: x=1 (bit0), x=2 (bit1), x=4 (bit2)
    localparam NUM_BYTES = 8'd94;
    localparam NUM_NULLS = 8'd64;
    
    localparam DELAY_SHORT = 24'd27000;
    localparam DELAY_LONG  = 24'd810000;
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
                
                // Dot 1 at x=1 (bit 0 = 00000001), y=32
                8'd3:  begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd4:  begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd5:  begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd6:  begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd7:  begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd8:  begin current_byte = 8'h01; post_delay = DELAY_SHORT; end  // x=1 (bit 0)
                8'd9:  begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd10: begin current_byte = 8'h20; post_delay = DELAY_SHORT; end  // y=32
                8'd11: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 2 at x=2 (bit 1 = 00000010), y=64
                8'd12: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd13: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd14: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd15: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd16: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd17: begin current_byte = 8'h02; post_delay = DELAY_SHORT; end  // x=2 (bit 1)
                8'd18: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd19: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end  // y=64
                8'd20: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 3 at x=4 (bit 2 = 00000100), y=96
                8'd21: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd22: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd23: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd24: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd25: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd26: begin current_byte = 8'h04; post_delay = DELAY_SHORT; end  // x=4 (bit 2)
                8'd27: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd28: begin current_byte = 8'h60; post_delay = DELAY_SHORT; end  // y=96
                8'd29: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
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
