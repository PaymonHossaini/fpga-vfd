/*
 * VFD Graphics Writer Module
 * Writes bitmap images to Noritake GU256x128C VFD Display
 * 
 * The GU256x128C supports graphics mode for pixel-level control.
 * This module implements the protocol for writing image data.
 */

module vfd_graphics_writer #(
    parameter IMAGE_WIDTH = 256,
    parameter IMAGE_HEIGHT = 128
)(
    input wire clk,
    input wire rst,
    input wire start,           // Pulse to start image write
    input wire ready,           // VFD READY signal
    output reg [7:0] data_bus,  // 8-bit data bus to VFD
    output reg wr_n,            // Write strobe (active low)
    output reg busy,            // High while writing
    output reg done             // Pulse when complete
);

    // FSM States
    localparam STATE_IDLE          = 4'd0;
    localparam STATE_WAIT_READY    = 4'd1;
    localparam STATE_SEND_CMD      = 4'd2;
    localparam STATE_PULSE_WR      = 4'd3;
    localparam STATE_NEXT_BYTE     = 4'd4;
    localparam STATE_DONE          = 4'd5;

    // Command sequence for graphics write
    localparam CMD_GRAPHICS_MODE   = 8'h02;  // Enter graphics mode
    localparam CMD_GRAPHICS_WRITE  = 8'h47;  // Graphics write command ('G')
    
    // Internal registers
    reg [3:0] state;
    reg [3:0] cmd_index;         // Which command in sequence
    reg [14:0] pixel_addr;       // Address into image ROM (0-4095)
    reg [7:0] rom_data;          // Data from image ROM
    reg [3:0] wr_pulse_count;    // Counter for WR pulse timing
    
    // Image ROM instance
    wire [7:0] image_data;
    image_rom rom_inst (
        .addr(pixel_addr),
        .data(image_data)
    );
    
    // Calculate total bytes to write (256 * 128 / 8 = 4096 bytes)
    localparam TOTAL_BYTES = (IMAGE_WIDTH * IMAGE_HEIGHT) / 8;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STATE_IDLE;
            data_bus <= 8'hFF;
            wr_n <= 1'b1;
            busy <= 1'b0;
            done <= 1'b0;
            cmd_index <= 4'd0;
            pixel_addr <= 15'd0;
            wr_pulse_count <= 4'd0;
        end else begin
            // Default outputs
            done <= 1'b0;
            
            case (state)
                STATE_IDLE: begin
                    busy <= 1'b0;
                    wr_n <= 1'b1;
                    data_bus <= 8'hFF;
                    pixel_addr <= 15'd0;
                    cmd_index <= 4'd0;
                    
                    if (start) begin
                        busy <= 1'b1;
                        state <= STATE_WAIT_READY;
                    end
                end
                
                STATE_WAIT_READY: begin
                    // Wait for VFD to be ready
                    if (ready) begin
                        state <= STATE_SEND_CMD;
                        
                        // Determine what to send based on command index
                        case (cmd_index)
                            4'd0: data_bus <= CMD_GRAPHICS_MODE;   // Graphics mode
                            4'd1: data_bus <= CMD_GRAPHICS_WRITE;  // Graphics write command
                            4'd2: data_bus <= 8'h00;               // X position low byte
                            4'd3: data_bus <= 8'h00;               // X position high byte
                            4'd4: data_bus <= 8'h00;               // Y position
                            4'd5: data_bus <= IMAGE_WIDTH[7:0];    // Width low byte
                            4'd6: data_bus <= IMAGE_WIDTH[15:8];   // Width high byte
                            4'd7: data_bus <= IMAGE_HEIGHT[7:0];   // Height
                            default: data_bus <= image_data;       // Pixel data
                        endcase
                    end
                end
                
                STATE_SEND_CMD: begin
                    // Assert WR signal
                    if (ready) begin
                        wr_n <= 1'b0;
                        wr_pulse_count <= 4'd0;
                        state <= STATE_PULSE_WR;
                    end
                end
                
                STATE_PULSE_WR: begin
                    // Hold WR low for a few clock cycles (adjust for timing)
                    wr_pulse_count <= wr_pulse_count + 1;
                    if (wr_pulse_count >= 4'd5) begin
                        wr_n <= 1'b1;
                        state <= STATE_NEXT_BYTE;
                    end
                end
                
                STATE_NEXT_BYTE: begin
                    // Move to next byte
                    if (cmd_index < 4'd7) begin
                        // Still sending command sequence
                        cmd_index <= cmd_index + 1;
                        state <= STATE_WAIT_READY;
                    end else if (pixel_addr < TOTAL_BYTES - 1) begin
                        // Send image data
                        pixel_addr <= pixel_addr + 1;
                        state <= STATE_WAIT_READY;
                    end else begin
                        // All data sent
                        state <= STATE_DONE;
                    end
                end
                
                STATE_DONE: begin
                    done <= 1'b1;
                    busy <= 1'b0;
                    state <= STATE_IDLE;
                end
                
                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule
