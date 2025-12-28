// VFD Graphics Test v53 - Fix ROM timing
// Read ROM in WAIT_RDY state so data is ready for SETUP

module vfd_graphics_v53 (
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
    
    // 64 nulls + ESC @(2) + CLR(1) + 4 dots × 9 bytes = 103 bytes
    localparam NUM_BYTES = 8'd103;
    localparam NUM_NULLS = 8'd64;
    
    localparam DELAY_SHORT = 24'd27000;    // 1ms
    localparam DELAY_LONG  = 24'd810000;   // 30ms
    localparam SETUP_TIME  = 8'd27;
    localparam PULSE_TIME  = 8'd54;
    localparam HOLD_TIME   = 8'd27;
    
    // ROM for command bytes
    reg [7:0] rom_data [0:38];
    reg [7:0] current_byte;
    reg is_long_delay;
    
    initial begin
        // ESC @
        rom_data[0] = 8'h1B;
        rom_data[1] = 8'h40;
        // CLR
        rom_data[2] = 8'h0C;
        // Dot 1 at (50, 64)
        rom_data[3] = 8'h1F;
        rom_data[4] = 8'h28;
        rom_data[5] = 8'h64;
        rom_data[6] = 8'h10;
        rom_data[7] = 8'h01;
        rom_data[8] = 8'h32;
        rom_data[9] = 8'h00;
        rom_data[10] = 8'h40;
        rom_data[11] = 8'h00;
        // Dot 2 at (100, 64)
        rom_data[12] = 8'h1F;
        rom_data[13] = 8'h28;
        rom_data[14] = 8'h64;
        rom_data[15] = 8'h10;
        rom_data[16] = 8'h01;
        rom_data[17] = 8'h64;
        rom_data[18] = 8'h00;
        rom_data[19] = 8'h40;
        rom_data[20] = 8'h00;
        // Dot 3 at (150, 64)
        rom_data[21] = 8'h1F;
        rom_data[22] = 8'h28;
        rom_data[23] = 8'h64;
        rom_data[24] = 8'h10;
        rom_data[25] = 8'h01;
        rom_data[26] = 8'h96;
        rom_data[27] = 8'h00;
        rom_data[28] = 8'h40;
        rom_data[29] = 8'h00;
        // Dot 4 at (200, 64)
        rom_data[30] = 8'h1F;
        rom_data[31] = 8'h28;
        rom_data[32] = 8'h64;
        rom_data[33] = 8'h10;
        rom_data[34] = 8'h01;
        rom_data[35] = 8'hC8;
        rom_data[36] = 8'h00;
        rom_data[37] = 8'h40;
        rom_data[38] = 8'h00;
    end

    // Combinational ROM read (not registered)
    wire [7:0] rom_out;
    assign rom_out = (byte_idx < NUM_NULLS) ? 8'h00 : rom_data[byte_idx - NUM_NULLS];
    
    // Determine if long delay needed (combinational)
    wire need_long_delay;
    assign need_long_delay = (byte_idx >= NUM_NULLS) && (
        (byte_idx - NUM_NULLS == 8'd1) ||
        (byte_idx - NUM_NULLS == 8'd2) ||
        (byte_idx - NUM_NULLS == 8'd11) ||
        (byte_idx - NUM_NULLS == 8'd20) ||
        (byte_idx - NUM_NULLS == 8'd29) ||
        (byte_idx - NUM_NULLS == 8'd38)
    );

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
                // Use combinational ROM output directly
                data_bus <= rom_out;
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
                    delay_counter <= need_long_delay ? DELAY_LONG : DELAY_SHORT;
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
