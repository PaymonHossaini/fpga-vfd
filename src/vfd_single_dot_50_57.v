// VFD Single Dot Test - x=50, y=57
// Testing the 8th pixel down from top of drawimage box position
// This is bit 0 (b0) of the first byte-row at position (50,50)

module vfd_single_dot_50_57 (
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
    reg [7:0] wr_timer;
    reg [7:0] byte_idx;
    
    localparam NUM_BYTES = 8'd76;  // 64 nulls + 12 bytes
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
                
                // Draw single dot at x=50, y=57
                // Command: 1F 28 64 10 01 xL xH yL yH
                8'd3:  begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd4:  begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd5:  begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd6:  begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd7:  begin current_byte = 8'h01; post_delay = DELAY_SHORT; end  // pen = 1 (draw)
                8'd8:  begin current_byte = 8'h31; post_delay = DELAY_SHORT; end  // xL = 50
                8'd9:  begin current_byte = 8'h00; post_delay = DELAY_SHORT; end  // xH = 0
                8'd10: begin current_byte = 8'h39; post_delay = DELAY_SHORT; end  // yL = 57
                8'd11: begin current_byte = 8'h00; post_delay = DELAY_LONG; end   // yH = 0
                
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
                state <= STATE_WAIT_RDY;
            end
            
            STATE_WAIT_RDY: begin
                if (byte_idx >= NUM_BYTES) begin
                    state <= STATE_DONE;
                end else if (ready) begin
                    state <= STATE_SETUP;
                end
            end
            
            STATE_SETUP: begin
                data_bus <= current_byte;
                wr_timer <= 8'd0;
                state <= STATE_SETUP_HOLD;
            end
            
            STATE_SETUP_HOLD: begin
                if (wr_timer >= SETUP_TIME) begin
                    wr_n <= 1'b0;
                    wr_timer <= 8'd0;
                    state <= STATE_PULSE_WR;
                end else begin
                    wr_timer <= wr_timer + 1'b1;
                end
            end
            
            STATE_PULSE_WR: begin
                if (wr_timer >= PULSE_TIME) begin
                    wr_n <= 1'b1;
                    wr_timer <= 8'd0;
                    state <= STATE_HOLD;
                end else begin
                    wr_timer <= wr_timer + 1'b1;
                end
            end
            
            STATE_HOLD: begin
                if (wr_timer >= HOLD_TIME) begin
                    delay_counter <= 24'd0;
                    state <= STATE_POST_DELAY;
                end else begin
                    wr_timer <= wr_timer + 1'b1;
                end
            end
            
            STATE_POST_DELAY: begin
                if (delay_counter >= post_delay) begin
                    state <= STATE_NEXT;
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end
            
            STATE_NEXT: begin
                byte_idx <= byte_idx + 1'b1;
                state <= STATE_WAIT_RDY;
            end
            
            STATE_DONE: begin
                leds <= 6'b111111;
            end
        endcase
    end

endmodule
