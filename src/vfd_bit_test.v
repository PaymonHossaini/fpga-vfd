// VFD Bit Position Test
// Sends known patterns to determine correct bit mapping

module vfd_bit_test (
    input wire clk,
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
    reg [3:0] byte_idx;
    
    // Send: Clear + "0123456789"
    localparam NUM_BYTES = 4'd11;
    
    reg [7:0] current_byte;
    
    always @(*) begin
        case (byte_idx)
            4'd0: current_byte = 8'h0C;  // Clear
            4'd1: current_byte = 8'h30;  // '0'
            4'd2: current_byte = 8'h31;  // '1'
            4'd3: current_byte = 8'h32;  // '2'
            4'd4: current_byte = 8'h33;  // '3'
            4'd5: current_byte = 8'h34;  // '4'
            4'd6: current_byte = 8'h35;  // '5'
            4'd7: current_byte = 8'h36;  // '6'
            4'd8: current_byte = 8'h37;  // '7'
            4'd9: current_byte = 8'h38;  // '8'
            4'd10: current_byte = 8'h39; // '9'
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
                data_bus <= current_byte;  // NO bit reversal
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
        byte_idx <= 4'd0;
        wr_n <= 1'b1;
        data_bus <= 8'd0;
        leds <= 6'd0;
    end

endmodule
