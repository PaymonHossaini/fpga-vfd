// VFD Graphics Test v5 - Simple pattern to understand bit ordering
// Tang Nano 20K -> GU256x128C-3900B VFD

module vfd_graphics_v5 (
    input wire clk,           // 27 MHz
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    localparam STATE_INIT      = 3'd0;
    localparam STATE_WAIT_RDY  = 3'd1;
    localparam STATE_SETUP     = 3'd2;
    localparam STATE_PULSE_WR  = 3'd3;
    localparam STATE_HOLD      = 3'd4;
    localparam STATE_NEXT      = 3'd5;
    localparam STATE_DONE      = 3'd6;
    
    reg [2:0] state;
    reg [23:0] counter;
    reg [7:0] wr_timer;
    reg [5:0] byte_idx;
    
    // Try alternate GU-3900B format
    // Maybe: 0x1F 0x28 0x64 0x21 xL xH yL yH xSizeL xSizeH ySizeL ySizeH [data]
    localparam NUM_BYTES = 6'd21;
    
    reg [7:0] current_byte;
    
    always @(*) begin
        case (byte_idx)
            6'd0: current_byte = 8'h0C;  // Clear display
            
            // GU-3900B bit image command variant
            6'd1: current_byte = 8'h1F;  // US
            6'd2: current_byte = 8'h28;  // (
            6'd3: current_byte = 8'h64;  // d - different command group
            6'd4: current_byte = 8'h21;  // ! - monochrome BMP display
            6'd5: current_byte = 8'h01;  // xL = 1 (avoid 0,0)
            6'd6: current_byte = 8'h00;  // xH
            6'd7: current_byte = 8'h01;  // yL = 1
            6'd8: current_byte = 8'h00;  // yH
            6'd9: current_byte = 8'h08;  // xSize low (8 pixels = 1 byte)
            6'd10: current_byte = 8'h00; // xSize high
            6'd11: current_byte = 8'h08; // ySize low (8 rows)
            6'd12: current_byte = 8'h00; // ySize high
            
            // Simple diagonal pattern to understand ordering
            6'd13: current_byte = 8'h80; // Row 0: 10000000
            6'd14: current_byte = 8'h40; // Row 1: 01000000
            6'd15: current_byte = 8'h20; // Row 2: 00100000
            6'd16: current_byte = 8'h10; // Row 3: 00010000
            6'd17: current_byte = 8'h08; // Row 4: 00001000
            6'd18: current_byte = 8'h04; // Row 5: 00000100
            6'd19: current_byte = 8'h02; // Row 6: 00000010
            6'd20: current_byte = 8'h01; // Row 7: 00000001
            
            default: current_byte = 8'h00;
        endcase
    end
    
    always @(posedge clk) begin
        case (state)
            STATE_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_idx <= 6'd0;
                leds <= 6'b000001;
                
                if (counter < 24'd2700000) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 24'd0;
                    state <= STATE_WAIT_RDY;
                end
            end
            
            STATE_WAIT_RDY: begin
                wr_n <= 1'b1;
                leds <= 6'b000010;
                
                if (ready || counter > 24'd50000) begin
                    state <= STATE_SETUP;
                    counter <= 24'd0;
                end else begin
                    counter <= counter + 1;
                end
            end
            
            STATE_SETUP: begin
                data_bus <= current_byte;
                wr_n <= 1'b1;
                wr_timer <= 8'd0;
                leds <= 6'b000100;
                state <= STATE_PULSE_WR;
            end
            
            STATE_PULSE_WR: begin
                wr_n <= 1'b0;
                leds <= 6'b001000;
                
                if (wr_timer < 8'd20) begin
                    wr_timer <= wr_timer + 1;
                end else begin
                    wr_timer <= 8'd0;
                    state <= STATE_HOLD;
                end
            end
            
            STATE_HOLD: begin
                wr_n <= 1'b1;
                leds <= 6'b010000;
                
                if (wr_timer < 8'd20) begin
                    wr_timer <= wr_timer + 1;
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
        state <= STATE_INIT;
        counter <= 24'd0;
        wr_timer <= 8'd0;
        byte_idx <= 6'd0;
        wr_n <= 1'b1;
        data_bus <= 8'd0;
        leds <= 6'd0;
    end

endmodule
