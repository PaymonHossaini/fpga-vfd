// VFD Graphics Test v64 - Systematic x-coordinate test
// Tests different x values to isolate the bit pattern issue
// Change TEST_X value to test different coordinates

module vfd_graphics_v64_x_test (
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
    
    // 64 nulls + ESC @(2) + CLR(1) + 1 dot × 9 bytes = 76 bytes
    localparam NUM_BYTES = 8'd76;
    localparam NUM_NULLS = 8'd64;
    
    localparam DELAY_SHORT = 24'd27000;    // 1ms between bytes
    localparam DELAY_LONG  = 24'd810000;   // 30ms after init/clear
    localparam SETUP_TIME  = 8'd27;        // ~1us data setup
    localparam PULSE_TIME  = 8'd54;        // ~2us WR pulse
    localparam HOLD_TIME   = 8'd27;        // ~1us data hold
    
    // Change TEST_X to test different coordinate values
    // Working: 128 (0x80)
    // Broken?: 100 (0x64)
    localparam TEST_X = 8'd100;  // <-- CHANGE THIS VALUE TO TEST
    
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
                
                // Single dot at (TEST_X, 64)
                8'd3:  begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end
                8'd4:  begin current_byte = 8'h28; post_delay = DELAY_SHORT; end
                8'd5:  begin current_byte = 8'h64; post_delay = DELAY_SHORT; end
                8'd6:  begin current_byte = 8'h10; post_delay = DELAY_SHORT; end
                8'd7:  begin current_byte = 8'h01; post_delay = DELAY_SHORT; end
                8'd8:  begin current_byte = TEST_X; post_delay = DELAY_SHORT; end  // xL = TEST_X
                8'd9:  begin current_byte = 8'h00; post_delay = DELAY_SHORT; end  // xH = 0
                8'd10: begin current_byte = 8'h40; post_delay = DELAY_SHORT; end  // yL = 64
                8'd11: begin current_byte = 8'h00; post_delay = DELAY_LONG; end   // yH = 0
                
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
                else
                    state <= STATE_PULSE_WR;
            end
            
            STATE_PULSE_WR: begin
                wr_n <= 1'b0;
                delay_counter <= PULSE_TIME;
                state <= STATE_HOLD;
            end
            
            STATE_HOLD: begin
                wr_n <= 1'b1;
                delay_counter <= HOLD_TIME;
                state <= STATE_POST_DELAY;
            end
            
            STATE_POST_DELAY: begin
                if (delay_counter > 0)
                    delay_counter <= delay_counter - 1;
                else begin
                    if (byte_idx < NUM_BYTES - 1) begin
                        byte_idx <= byte_idx + 1;
                        state <= STATE_SETUP;
                        delay_counter <= post_delay;
                    end else begin
                        state <= STATE_DONE;
                    end
                end
            end
            
            STATE_DONE: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
            end
            
            default: state <= STATE_INIT;
        endcase
    end

endmodule
