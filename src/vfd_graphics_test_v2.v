// VFD Graphics Test v2 - Correct GU-3000 Command Format
// Tang Nano 20K -> GU256x128C VFD
// Uses proper GU-3000 real-time bit image command: 0x1F 0x28 0x66 0x11

module vfd_graphics_test_v2 (
    input wire clk,           // 27 MHz
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds     // Debug LEDs
);

    // State machine
    localparam STATE_INIT_WAIT     = 4'd0;
    localparam STATE_WAIT_READY    = 4'd1;
    localparam STATE_SEND_DATA     = 4'd2;
    localparam STATE_PULSE_WR      = 4'd3;
    localparam STATE_RELEASE_WR    = 4'd4;
    localparam STATE_NEXT_BYTE     = 4'd5;
    localparam STATE_DONE          = 4'd6;
    
    reg [3:0] state;
    
    // Timing counters
    reg [23:0] init_counter;       // Power-on delay (~100ms)
    reg [7:0]  wr_counter;         // WR pulse width
    reg [15:0] ready_timeout;      // Ready timeout
    
    // Byte sequence index
    reg [7:0] byte_index;
    
    // GU-3000 Real-time bit image command for 32x8 pattern at (0,0)
    // Command: 0x1F 0x28 0x66 0x11 xL xH yL yH 0x01 [data]
    // Header: 9 bytes + 32 data bytes = 41 bytes total
    localparam TOTAL_BYTES = 8'd41;
    
    reg [7:0] current_byte;
    
    // Generate current byte based on index
    always @(*) begin
        case (byte_index)
            // GU-3000 Real-time bit image command header
            8'd0: current_byte = 8'h1F;  // US - command start
            8'd1: current_byte = 8'h28;  // '(' - command group
            8'd2: current_byte = 8'h66;  // 'f' - image command group
            8'd3: current_byte = 8'h11;  // Real-time bit image display
            8'd4: current_byte = 8'h00;  // X position low byte (0)
            8'd5: current_byte = 8'h00;  // X position high byte
            8'd6: current_byte = 8'h00;  // Y position low byte (0)
            8'd7: current_byte = 8'h00;  // Y position high byte
            8'd8: current_byte = 8'h01;  // Display mode (1 = normal/OR)
            
            // Pixel data - 32 bytes for 32x8 image (4 bytes per row x 8 rows)
            // Row 0: solid line
            8'd9:  current_byte = 8'hFF;
            8'd10: current_byte = 8'hFF;
            8'd11: current_byte = 8'hFF;
            8'd12: current_byte = 8'hFF;
            
            // Row 1: alternating 0xAA
            8'd13: current_byte = 8'hAA;
            8'd14: current_byte = 8'hAA;
            8'd15: current_byte = 8'hAA;
            8'd16: current_byte = 8'hAA;
            
            // Row 2: alternating 0x55
            8'd17: current_byte = 8'h55;
            8'd18: current_byte = 8'h55;
            8'd19: current_byte = 8'h55;
            8'd20: current_byte = 8'h55;
            
            // Row 3: checkerboard
            8'd21: current_byte = 8'hAA;
            8'd22: current_byte = 8'h55;
            8'd23: current_byte = 8'hAA;
            8'd24: current_byte = 8'h55;
            
            // Row 4: checkerboard inverse
            8'd25: current_byte = 8'h55;
            8'd26: current_byte = 8'hAA;
            8'd27: current_byte = 8'h55;
            8'd28: current_byte = 8'hAA;
            
            // Row 5: 0x0F pattern
            8'd29: current_byte = 8'h0F;
            8'd30: current_byte = 8'h0F;
            8'd31: current_byte = 8'h0F;
            8'd32: current_byte = 8'h0F;
            
            // Row 6: 0xF0 pattern
            8'd33: current_byte = 8'hF0;
            8'd34: current_byte = 8'hF0;
            8'd35: current_byte = 8'hF0;
            8'd36: current_byte = 8'hF0;
            
            // Row 7: solid line
            8'd37: current_byte = 8'hFF;
            8'd38: current_byte = 8'hFF;
            8'd39: current_byte = 8'hFF;
            8'd40: current_byte = 8'hFF;
            
            default: current_byte = 8'h00;
        endcase
    end
    
    // Main state machine
    always @(posedge clk) begin
        case (state)
            STATE_INIT_WAIT: begin
                // Wait ~100ms for VFD to initialize
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_index <= 8'd0;
                leds <= 6'b000001;
                
                if (init_counter < 24'd2700000) begin
                    init_counter <= init_counter + 1;
                end else begin
                    state <= STATE_WAIT_READY;
                end
            end
            
            STATE_WAIT_READY: begin
                wr_n <= 1'b1;
                leds <= 6'b000010;
                ready_timeout <= ready_timeout + 1;
                
                if (ready) begin
                    state <= STATE_SEND_DATA;
                    ready_timeout <= 16'd0;
                end else if (ready_timeout >= 16'd65000) begin
                    // Timeout - try anyway
                    state <= STATE_SEND_DATA;
                    ready_timeout <= 16'd0;
                end
            end
            
            STATE_SEND_DATA: begin
                data_bus <= current_byte;
                wr_n <= 1'b1;
                wr_counter <= 8'd0;
                leds <= 6'b000100;
                state <= STATE_PULSE_WR;
            end
            
            STATE_PULSE_WR: begin
                wr_n <= 1'b0;
                leds <= 6'b001000;
                
                if (wr_counter < 8'd15) begin
                    wr_counter <= wr_counter + 1;
                end else begin
                    state <= STATE_RELEASE_WR;
                    wr_counter <= 8'd0;
                end
            end
            
            STATE_RELEASE_WR: begin
                wr_n <= 1'b1;
                leds <= 6'b010000;
                
                if (wr_counter < 8'd15) begin
                    wr_counter <= wr_counter + 1;
                end else begin
                    state <= STATE_NEXT_BYTE;
                end
            end
            
            STATE_NEXT_BYTE: begin
                if (byte_index < TOTAL_BYTES - 1) begin
                    byte_index <= byte_index + 1;
                    state <= STATE_WAIT_READY;
                end else begin
                    state <= STATE_DONE;
                end
            end
            
            STATE_DONE: begin
                wr_n <= 1'b1;
                leds[4:0] <= 5'b00000;
                leds[5] <= init_counter[23];
                init_counter <= init_counter + 1;
            end
            
            default: begin
                state <= STATE_INIT_WAIT;
            end
        endcase
    end
    
    initial begin
        state <= STATE_INIT_WAIT;
        init_counter <= 24'd0;
        wr_counter <= 8'd0;
        ready_timeout <= 16'd0;
        byte_index <= 8'd0;
        wr_n <= 1'b1;
        data_bus <= 8'd0;
        leds <= 6'd0;
    end

endmodule
