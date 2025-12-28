// VFD Graphics Test v59 - All bus values forced to 1
// Simple test to verify all bits on the data bus work

module vfd_graphics_v59_all_ones (
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
    
    // 64 nulls + all 1's bytes for verification
    localparam NUM_BYTES = 8'd100;  // 64 nulls + 36 all-ones
    localparam NUM_NULLS = 8'd64;
    
    localparam DELAY_SHORT = 24'd27000;    // 1ms
    localparam DELAY_LONG  = 24'd810000;   // 30ms
    localparam SETUP_TIME  = 8'd27;
    localparam PULSE_TIME  = 8'd54;
    localparam HOLD_TIME   = 8'd27;
    
    reg [7:0] current_byte;
    reg [23:0] post_delay;
    reg valid_byte;
    
    always @(*) begin
        valid_byte = 1'b1;
        if (byte_idx < NUM_NULLS) begin
            // Flush buffer with nulls
            current_byte = 8'h00;
            post_delay = DELAY_SHORT;
        end else begin
            case (byte_idx - NUM_NULLS)
                // Initialize display: ESC @
                8'd0: begin current_byte = 8'h1B; post_delay = DELAY_SHORT; end
                8'd1: begin current_byte = 8'h40; post_delay = DELAY_LONG; end
                
                // Clear screen
                8'd2: begin current_byte = 8'h0C; post_delay = DELAY_LONG; end
                
                // Test command with all 0xFF (0b11111111) bytes to verify all bits
                // Send 32 bytes of 0xFF to make sure every bit position works
                8'd3:  begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd4:  begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd5:  begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd6:  begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd7:  begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd8:  begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd9:  begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd10: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd11: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd12: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd13: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd14: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd15: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd16: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd17: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd18: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd19: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd20: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd21: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd22: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd23: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd24: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd25: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd26: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd27: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd28: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd29: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd30: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd31: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd32: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd33: begin current_byte = 8'hFF; post_delay = DELAY_SHORT; end
                8'd34: begin current_byte = 8'hFF; post_delay = DELAY_LONG; end
                
                default: begin 
                    current_byte = 8'h00; 
                    post_delay = DELAY_SHORT; 
                    valid_byte = 1'b0;
                end
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
                wr_n <= 1'b1;
                data_bus <= current_byte;
                leds <= 6'b000100;
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
                    wr_timer <= 8'd0;
                    state <= STATE_POST_DELAY;
                    delay_counter <= 24'd0;
                end
            end
            
            STATE_POST_DELAY: begin
                wr_n <= 1'b1;
                leds <= 6'b010001;
                if (delay_counter < post_delay) begin
                    delay_counter <= delay_counter + 1;
                end else begin
                    delay_counter <= 24'd0;
                    if (valid_byte && byte_idx < NUM_BYTES - 1) begin
                        byte_idx <= byte_idx + 1;
                        state <= STATE_SETUP;
                    end else begin
                        leds <= 6'b100000;
                        state <= STATE_DONE;
                    end
                end
            end
            
            STATE_DONE: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                leds <= 6'b111111;
                // Hold in done state
            end
            
            default: begin
                state <= STATE_INIT;
            end
        endcase
    end

endmodule
