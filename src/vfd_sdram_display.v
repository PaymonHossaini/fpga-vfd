// VFD SDRAM Animation Display
// Streams frames from PC via UART into SDRAM, then plays from SDRAM to VFD
//
// Operation:
// 1. Wait for UART data - store frames into SDRAM
// 2. Once enough frames received, start playback loop
// 3. Continues receiving frames while playing (ping-pong regions)

module vfd_image_display (
    input wire clk,                  // 27MHz
    output reg [7:0] data_bus,
    output reg wr_n,
    input wire ready,
    output reg [5:0] leds,
    output wire uart_tx_pin,
    input wire uart_rx_pin,
    
    // SDRAM interface
    output wire       sdram_clk,
    output wire       sdram_cke,
    output wire       sdram_cs_n,
    output wire       sdram_ras_n,
    output wire       sdram_cas_n,
    output wire       sdram_wen_n,
    inout  [31:0]     sdram_dq,
    output [10:0]     sdram_addr,
    output [1:0]      sdram_ba,
    output [3:0]      sdram_dqm
);

    assign uart_tx_pin = 1'b1;

    // ========== Clock Generation ==========
    wire clk_main;      // 54MHz main clock
    wire clk_sdram;     // 54MHz 180-degree shifted
    wire pll_lock;
    
    sdram_pll pll_inst (
        .clkin(clk),
        .clkout(clk_main),
        .clkoutp(clk_sdram),
        .lock(pll_lock)
    );
    
    wire resetn = pll_lock;

    // ========== SDRAM Controller ==========
    reg        sdram_rd;
    reg        sdram_wr;
    reg        sdram_refresh;
    reg [22:0] sdram_address;
    reg [7:0]  sdram_din;
    wire [7:0] sdram_dout;
    wire       sdram_data_ready;
    wire       sdram_busy;
    
    sdram #(
        .FREQ(54_000_000)
    ) sdram_ctrl (
        .SDRAM_DQ(sdram_dq),
        .SDRAM_A(sdram_addr),
        .SDRAM_BA(sdram_ba),
        .SDRAM_nCS(sdram_cs_n),
        .SDRAM_nWE(sdram_wen_n),
        .SDRAM_nRAS(sdram_ras_n),
        .SDRAM_nCAS(sdram_cas_n),
        .SDRAM_CLK(sdram_clk),
        .SDRAM_CKE(sdram_cke),
        .SDRAM_DQM(sdram_dqm),
        
        .clk(clk_main),
        .clk_sdram(clk_sdram),
        .resetn(resetn),
        .rd(sdram_rd),
        .wr(sdram_wr),
        .refresh(sdram_refresh),
        .addr(sdram_address),
        .din(sdram_din),
        .dout(sdram_dout),
        .data_ready(sdram_data_ready),
        .busy(sdram_busy)
    );

    // ========== UART Receiver ==========
    // 1Mbaud for fast frame transfer
    wire [7:0] uart_data;
    wire uart_valid;
    
    uart_rx #(
        .CLK_FREQ(54_000_000),
        .BAUD_RATE(1000000)
    ) uart_inst (
        .clk(clk_main),
        .rx(uart_rx_pin),
        .data(uart_data),
        .valid(uart_valid),
        .busy()
    );

    // ========== Refresh Timer ==========
    // Need refresh every ~15us = 810 cycles @ 54MHz
    reg [9:0] refresh_counter;
    reg need_refresh;
    
    always @(posedge clk_main) begin
        if (~resetn) begin
            refresh_counter <= 0;
            need_refresh <= 0;
        end else begin
            if (refresh_counter >= 10'd800) begin
                refresh_counter <= 0;
                need_refresh <= 1;
            end else begin
                refresh_counter <= refresh_counter + 1;
                if (sdram_refresh && !sdram_busy)
                    need_refresh <= 0;
            end
        end
    end

    // ========== State Machine ==========
    localparam BYTES_PER_FRAME = 4096;
    localparam MAX_FRAMES = 100;       // Store up to 100 frames in SDRAM
    
    // Main states
    localparam S_INIT           = 5'd0;
    localparam S_WAIT_UART      = 5'd1;
    localparam S_STORE_BYTE     = 5'd2;
    localparam S_STORE_WAIT     = 5'd3;
    localparam S_PLAYBACK_START = 5'd4;
    localparam S_HDR_SETUP      = 5'd5;
    localparam S_HDR_WR_LO      = 5'd6;
    localparam S_HDR_WR_HI      = 5'd7;
    localparam S_HDR_DELAY      = 5'd8;
    localparam S_HDR_NEXT       = 5'd9;
    localparam S_DMA_READ_REQ   = 5'd10;
    localparam S_DMA_READ_WAIT  = 5'd11;
    localparam S_DMA_WR_SETUP   = 5'd12;
    localparam S_DMA_WR_LO      = 5'd13;
    localparam S_DMA_WR_HI      = 5'd14;
    localparam S_DMA_NEXT       = 5'd15;
    localparam S_FRAME_WAIT     = 5'd16;
    localparam S_NEXT_FRAME     = 5'd17;
    localparam S_REFRESH        = 5'd18;
    
    reg [4:0] state;
    reg [4:0] state_after_refresh;
    reg [23:0] counter;
    reg [15:0] timer;
    reg [12:0] byte_idx;
    reg [6:0] frame_idx;           // Current playback frame
    reg [6:0] frames_loaded;       // Number of complete frames in SDRAM
    reg [22:0] write_addr;         // SDRAM write address
    reg [22:0] read_addr;          // SDRAM read address
    reg [7:0] latched_byte;
    reg playback_active;
    
    // Header timing (scaled for 54MHz)
    localparam HDR_TIME  = 16'd540;   // ~10us
    localparam HDR_DELAY = 16'd5400;  // ~100us
    localparam HDR_LONG  = 16'd108000;
    localparam FRAME_DELAY = 24'd19440000;  // 360ms at 54MHz
    
    // Header bytes: 02 44 00 46 00 00 00 10
    wire [7:0] header_byte;
    assign header_byte = (byte_idx == 0) ? 8'h02 :
                         (byte_idx == 1) ? 8'h44 :
                         (byte_idx == 2) ? 8'h00 :
                         (byte_idx == 3) ? 8'h46 :
                         (byte_idx == 4) ? 8'h00 :
                         (byte_idx == 5) ? 8'h00 :
                         (byte_idx == 6) ? 8'h00 :
                         (byte_idx == 7) ? 8'h10 : 8'h00;

    always @(posedge clk_main) begin
        if (~resetn) begin
            state <= S_INIT;
            wr_n <= 1'b1;
            data_bus <= 8'h00;
            sdram_rd <= 0;
            sdram_wr <= 0;
            sdram_refresh <= 0;
            frames_loaded <= 0;
            write_addr <= 0;
            playback_active <= 0;
            counter <= 0;
            leds <= 6'b000001;
        end else begin
            // Default: no SDRAM commands
            sdram_rd <= 0;
            sdram_wr <= 0;
            sdram_refresh <= 0;
            
            // Handle refresh requests in most states
            if (need_refresh && !sdram_busy && state != S_REFRESH && 
                state != S_STORE_WAIT && state != S_DMA_READ_WAIT) begin
                state_after_refresh <= state;
                state <= S_REFRESH;
            end else begin
                case (state)
                    S_INIT: begin
                        wr_n <= 1'b1;
                        byte_idx <= 0;
                        frame_idx <= 0;
                        timer <= 0;
                        write_addr <= 0;
                        frames_loaded <= 0;
                        leds <= 6'b000001;
                        
                        // Wait for SDRAM init + small delay
                        if (counter < 24'd5400000) begin  // 100ms
                            counter <= counter + 1;
                        end else begin
                            counter <= 0;
                            state <= S_WAIT_UART;
                        end
                    end
                    
                    // ========== UART LOADING ==========
                    S_WAIT_UART: begin
                        leds <= {1'b0, frames_loaded[4:0]};
                        
                        if (uart_valid) begin
                            sdram_din <= uart_data;
                            sdram_address <= write_addr;
                            state <= S_STORE_BYTE;
                        end else if (playback_active && frames_loaded > 0) begin
                            // Start playback if we have at least 1 frame
                            state <= S_PLAYBACK_START;
                        end
                    end
                    
                    S_STORE_BYTE: begin
                        if (!sdram_busy) begin
                            sdram_wr <= 1;
                            state <= S_STORE_WAIT;
                        end
                    end
                    
                    S_STORE_WAIT: begin
                        if (!sdram_busy && !sdram_wr) begin
                            write_addr <= write_addr + 1;
                            
                            // Check if frame complete
                            if (write_addr[11:0] == 12'hFFF) begin
                                frames_loaded <= frames_loaded + 1;
                                playback_active <= 1;
                            end
                            
                            state <= S_WAIT_UART;
                        end
                    end
                    
                    // ========== PLAYBACK ==========
                    S_PLAYBACK_START: begin
                        byte_idx <= 0;
                        read_addr <= {frame_idx, 12'b0};  // Frame start address
                        leds <= 6'b100000 | frame_idx[4:0];
                        state <= S_HDR_SETUP;
                    end
                    
                    // === HEADER ===
                    S_HDR_SETUP: begin
                        data_bus <= header_byte;
                        wr_n <= 1'b1;
                        timer <= timer + 1;
                        if (timer >= HDR_TIME) begin
                            timer <= 0;
                            state <= S_HDR_WR_LO;
                        end
                    end
                    
                    S_HDR_WR_LO: begin
                        wr_n <= 1'b0;
                        timer <= timer + 1;
                        if (timer >= HDR_TIME) begin
                            timer <= 0;
                            state <= S_HDR_WR_HI;
                        end
                    end
                    
                    S_HDR_WR_HI: begin
                        wr_n <= 1'b1;
                        timer <= timer + 1;
                        if (timer >= HDR_TIME) begin
                            timer <= 0;
                            state <= S_HDR_DELAY;
                        end
                    end
                    
                    S_HDR_DELAY: begin
                        timer <= timer + 1;
                        if (timer >= (byte_idx < 2 ? HDR_LONG : HDR_DELAY)) begin
                            timer <= 0;
                            state <= S_HDR_NEXT;
                        end
                    end
                    
                    S_HDR_NEXT: begin
                        byte_idx <= byte_idx + 1;
                        if (byte_idx >= 7) begin
                            byte_idx <= 0;
                            state <= S_DMA_READ_REQ;
                        end else begin
                            state <= S_HDR_SETUP;
                        end
                    end
                    
                    // === DMA DATA ===
                    S_DMA_READ_REQ: begin
                        if (!sdram_busy) begin
                            sdram_address <= read_addr;
                            sdram_rd <= 1;
                            state <= S_DMA_READ_WAIT;
                        end
                    end
                    
                    S_DMA_READ_WAIT: begin
                        if (sdram_data_ready) begin
                            latched_byte <= sdram_dout;
                            state <= S_DMA_WR_SETUP;
                        end
                    end
                    
                    S_DMA_WR_SETUP: begin
                        data_bus <= latched_byte;
                        wr_n <= 1'b1;
                        state <= S_DMA_WR_LO;
                    end
                    
                    S_DMA_WR_LO: begin
                        wr_n <= 1'b0;
                        state <= S_DMA_WR_HI;
                    end
                    
                    S_DMA_WR_HI: begin
                        wr_n <= 1'b1;
                        state <= S_DMA_NEXT;
                    end
                    
                    S_DMA_NEXT: begin
                        byte_idx <= byte_idx + 1;
                        read_addr <= read_addr + 1;
                        if (byte_idx >= BYTES_PER_FRAME - 1) begin
                            byte_idx <= 0;
                            state <= S_FRAME_WAIT;
                        end else begin
                            state <= S_DMA_READ_REQ;
                        end
                    end
                    
                    S_FRAME_WAIT: begin
                        timer <= timer + 1;
                        // Wait + check for new UART data
                        if (uart_valid) begin
                            // Store incoming byte while waiting
                            sdram_din <= uart_data;
                            sdram_address <= write_addr;
                            sdram_wr <= !sdram_busy;
                        end
                        
                        if (timer >= FRAME_DELAY[15:0] && counter >= FRAME_DELAY[23:16]) begin
                            timer <= 0;
                            counter <= 0;
                            state <= S_NEXT_FRAME;
                        end else if (timer == 16'hFFFF) begin
                            timer <= 0;
                            counter <= counter + 1;
                        end
                    end
                    
                    S_NEXT_FRAME: begin
                        if (frame_idx >= frames_loaded - 1) begin
                            frame_idx <= 0;
                        end else begin
                            frame_idx <= frame_idx + 1;
                        end
                        state <= S_PLAYBACK_START;
                    end
                    
                    S_REFRESH: begin
                        if (!sdram_busy) begin
                            sdram_refresh <= 1;
                            state <= state_after_refresh;
                        end
                    end
                    
                    default: state <= S_INIT;
                endcase
            end
        end
    end

endmodule
