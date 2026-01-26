// VFD Hello - Strict Timing Test
// Each action happens in a separate state

module vfd_hello_strict (
    input wire clk,
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds
);

    localparam STATE_INIT           = 4'd0;
    localparam STATE_WAIT_RDY       = 4'd1;  // Cycle 1: Wait for ready
    localparam STATE_WR_LOW         = 4'd2;  // Cycle 2: Push WR low
    localparam STATE_PUT_BYTE       = 4'd3;  // Cycle 3: Put byte on bus (WR already low)
    localparam STATE_WAIT_ONE       = 4'd4;  // Cycle 4: Hold WR low
    localparam STATE_WAIT_TWO       = 4'd5;  // Cycle 5: Hold WR low
    localparam STATE_WAIT_THREE     = 4'd6;  // Cycle 6: Hold WR low + data
    localparam STATE_WR_HIGH        = 4'd7;  // Cycle 7: Push WR high (LATCH)
    localparam STATE_WAIT_RDY_LOW   = 4'd8;  // Cycle 8: Wait for ready low
    localparam STATE_NEXT           = 4'd9;
    localparam STATE_DONE           = 4'd10;
    
    reg [3:0] state;
    reg [23:0] counter;
    reg [23:0] timeout;
    reg [3:0] byte_idx;
    
    localparam NUM_BYTES = 4'd6;  // Clear + Hello
    localparam TIMEOUT = 24'd270000; // 10ms timeout
    
    reg [7:0] current_byte;
    
    always @(*) begin
        case (byte_idx)
            4'd0: current_byte = 8'h0C;  // Clear
            4'd1: current_byte = 8'h48;  // 'H'
            4'd2: current_byte = 8'h65;  // 'e'
            4'd3: current_byte = 8'h6C;  // 'l'
            4'd4: current_byte = 8'h6C;  // 'l'
            4'd5: current_byte = 8'h6F;  // 'o'
            default: current_byte = 8'h00;
        endcase
    end
    
    always @(posedge clk) begin
        case (state)
            STATE_INIT: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                byte_idx <= 4'd0;
                leds <= 6'b000001;
                timeout <= 24'd0;
                
                if (counter < 24'd2700000) begin // 100ms startup
                    counter <= counter + 1;
                end else begin
                    counter <= 24'd0;
                    state <= STATE_WAIT_RDY;
                end
            end
            
            // Cycle 1: Wait for ready HIGH
            STATE_WAIT_RDY: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                leds <= {ready, 5'b00010};
                
                if (ready == 1'b1 || timeout > TIMEOUT) begin
                    timeout <= 24'd0;
                    state <= STATE_WR_LOW;
                end else begin
                    timeout <= timeout + 1;
                end
            end
            
            // Cycle 2: Push WR LOW
            STATE_WR_LOW: begin
                wr_n <= 1'b0;  // WR goes LOW
                data_bus <= 8'h00;  // Bus still clear
                leds <= 6'b000100;
                state <= STATE_PUT_BYTE;  // Next cycle immediately
            end
            
            // Cycle 3: Put byte on bus (WR already LOW)
            STATE_PUT_BYTE: begin
                wr_n <= 1'b0;  // Keep WR LOW
                data_bus <= current_byte;  // Byte appears now
                leds <= 6'b001000;
                state <= STATE_WAIT_ONE;  // Next cycle immediately
            end
            
            // Cycle 4: Wait one cycle (byte stable, WR still LOW)
            STATE_WAIT_ONE: begin
                wr_n <= 1'b0;  // Keep WR LOW
                data_bus <= current_byte;  // Keep byte stable
                leds <= 6'b010000;
                state <= STATE_WAIT_TWO;  // Next cycle immediately
            end
            
            // Cycle 5: Wait another cycle (more setup time)
            STATE_WAIT_TWO: begin
                wr_n <= 1'b0;  // Keep WR LOW
                data_bus <= current_byte;  // Keep byte stable
                leds <= 6'b010001;
                state <= STATE_WAIT_THREE;  // Next cycle immediately
            end
            
            // Cycle 6: Wait third cycle (data stable, WR low)
            STATE_WAIT_THREE: begin
                wr_n <= 1'b0;  // Keep WR LOW
                data_bus <= current_byte;  // Keep byte stable
                leds <= 6'b010010;
                state <= STATE_WR_HIGH;  // Next cycle immediately
            end
            
            // Cycle 7: Push WR HIGH (LATCH on rising edge)
            STATE_WR_HIGH: begin
                wr_n <= 1'b1;  // WR goes HIGH
                data_bus <= current_byte;  // Keep data stable
                leds <= 6'b100000;
                timeout <= 24'd0;
                state <= STATE_WAIT_RDY_LOW;
            end
            
            // Cycle 6: Wait for ready LOW
            STATE_WAIT_RDY_LOW: begin
                wr_n <= 1'b1;
                data_bus <= 8'h00;
                leds <= {ready, 5'b10001};
                
                if (ready == 1'b0 || timeout > TIMEOUT) begin
                    timeout <= 24'd0;
                    state <= STATE_NEXT;
                end else begin
                    timeout <= timeout + 1;
                end
            end
            
            // Next byte
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
                data_bus <= 8'h00;
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
        timeout = 24'd0;
        byte_idx = 4'd0;
        wr_n = 1'b1;
        data_bus = 8'd0;
        leds = 6'd0;
    end

endmodule
