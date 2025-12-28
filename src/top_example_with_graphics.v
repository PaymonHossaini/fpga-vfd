/*
 * Example: Integrating Graphics Mode with Your Existing Character Display
 * 
 * This shows how to add image display capability to your existing setup.
 * You can switch between character mode and graphics mode with a button.
 */

module top_with_graphics (
    // Parallel interface signals
    input  wire ready,
    output wire wr_n,
    output wire [7:0] data_bus,
    
    // Button to trigger image display
    input  wire btn_image,      // Connect to S1 or S2 button on Tang Nano 20K
    
    // LED indicators
    output wire led,
    output wire led_ready,
    output wire led_state0,
    output wire led_state1
);

    // Internal clock
    wire clk;
    Gowin_OSC osc_inst (
        .oscout(clk)
    );
    
    // Button debouncing
    reg [19:0] btn_debounce;
    reg btn_image_sync, btn_image_prev;
    wire btn_image_pulse;
    
    always @(posedge clk) begin
        btn_image_sync <= btn_image;
        btn_image_prev <= btn_image_sync;
        
        if (btn_image_sync && !btn_image_prev) begin
            btn_debounce <= 20'hFFFFF;
        end else if (btn_debounce != 0) begin
            btn_debounce <= btn_debounce - 1;
        end
    end
    
    assign btn_image_pulse = (btn_debounce == 20'h00001);
    
    // Mode selection
    reg graphics_mode;
    always @(posedge clk) begin
        if (btn_image_pulse) begin
            graphics_mode <= 1'b1;  // Switch to graphics mode
        end
        if (graphics_done) begin
            graphics_mode <= 1'b0;  // Return to character mode when done
        end
    end
    
    // Character writer (your existing module)
    wire [7:0] char_data_bus;
    wire char_wr_n;
    vfd_test_writer char_writer (
        .clk(clk),
        .ready(ready && !graphics_mode),  // Only active when not in graphics mode
        .data_bus(char_data_bus),
        .wr_n(char_wr_n),
        .led(led),
        .led_ready(led_ready),
        .led_state0(led_state0),
        .led_state1(led_state1)
    );
    
    // Graphics writer (new module)
    wire [7:0] gfx_data_bus;
    wire gfx_wr_n;
    wire graphics_busy;
    wire graphics_done;
    
    vfd_graphics_writer graphics_writer (
        .clk(clk),
        .rst(1'b0),
        .start(btn_image_pulse),
        .ready(ready && graphics_mode),  // Only active in graphics mode
        .data_bus(gfx_data_bus),
        .wr_n(gfx_wr_n),
        .busy(graphics_busy),
        .done(graphics_done)
    );
    
    // Multiplexer: select between character and graphics mode
    assign data_bus = graphics_mode ? gfx_data_bus : char_data_bus;
    assign wr_n = graphics_mode ? gfx_wr_n : char_wr_n;

endmodule


/*
 * ALTERNATIVE: Simple auto-cycling demo
 * Shows characters for 5 seconds, then an image for 5 seconds, repeat
 */
module top_auto_cycle (
    input  wire ready,
    output wire wr_n,
    output wire [7:0] data_bus,
    output wire led,
    output wire led_ready,
    output wire led_state0,
    output wire led_state1
);

    wire clk;
    Gowin_OSC osc_inst (
        .oscout(clk)
    );
    
    // Timer for mode switching (5 seconds at 27 MHz)
    reg [27:0] timer;
    reg graphics_mode;
    reg start_graphics;
    wire graphics_done;
    
    localparam CYCLE_TIME = 28'd135_000_000;  // 5 seconds at 27 MHz
    
    always @(posedge clk) begin
        start_graphics <= 1'b0;
        
        if (timer < CYCLE_TIME) begin
            timer <= timer + 1;
        end else begin
            timer <= 0;
            graphics_mode <= ~graphics_mode;
            if (~graphics_mode) begin  // Switching to graphics mode
                start_graphics <= 1'b1;
            end
        end
        
        // Return to character mode after graphics completes
        if (graphics_done) begin
            graphics_mode <= 1'b0;
            timer <= 0;
        end
    end
    
    // Character and graphics writers (same as above)
    wire [7:0] char_data_bus, gfx_data_bus;
    wire char_wr_n, gfx_wr_n;
    
    vfd_test_writer char_writer (
        .clk(clk),
        .ready(ready && !graphics_mode),
        .data_bus(char_data_bus),
        .wr_n(char_wr_n),
        .led(led),
        .led_ready(led_ready),
        .led_state0(led_state0),
        .led_state1(led_state1)
    );
    
    vfd_graphics_writer graphics_writer (
        .clk(clk),
        .rst(1'b0),
        .start(start_graphics),
        .ready(ready && graphics_mode),
        .data_bus(gfx_data_bus),
        .wr_n(gfx_wr_n),
        .busy(),
        .done(graphics_done)
    );
    
    assign data_bus = graphics_mode ? gfx_data_bus : char_data_bus;
    assign wr_n = graphics_mode ? gfx_wr_n : char_wr_n;

endmodule
