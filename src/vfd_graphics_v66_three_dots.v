// VFD Graphics Test v66 - Three dots (based on v35)
// Tests three dots to isolate multi-command issue

module vfd_graphics_v66_three_dots (
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
    
    // 64 nulls + Init(2) + Clear(1) + 3 dots × 9 bytes = 94
    localparam NUM_BYTES = 8'd94;
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
                8'd0: begin current_byte = 8'h1B; post_delay = DELAY_SHORT; end
                8'd1: begin current_byte = 8'h40; post_delay = DELAY_LONG; end
                
                // Clear screen
                8'd2: begin current_byte = 8'h0C; post_delay = DELAY_LONG; end
                
                // Dot 1 at (10, 10)
                8'd3:  begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd4:  begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd5:  begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd6:  begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd7:  begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd8:  begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                8'd9:  begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd10: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                8'd11: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 2 at (100, 10) - Changed from 20 to 100 to test
                8'd12: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd13: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd14: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd15: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd16: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd17: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end  // 100 = 0x64
                8'd18: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd19: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                8'd20: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
                // Dot 3 at (30, 10)
                8'd21: begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd22: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd23: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd24: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd25: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd26: begin current_byte = 8'h1E; post_delay = DELAY_SHORT; end
                8'd27: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end
                8'd28: begin current_byte = 8'h0A; post_delay = DELAY_SHORT; end
                8'd29: begin current_byte = 8'h00; post_delay = DELAY_LONG; end
                
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
