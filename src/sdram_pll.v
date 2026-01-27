// PLL for SDRAM - generates main clock and 180-degree phase shifted clock
// Gowin-specific rPLL primitive for Tang Nano 20K
// Input: 27MHz, Output: 54MHz + 54MHz_180deg

module sdram_pll (
    input wire clkin,          // 27MHz input
    output wire clkout,        // 54MHz main clock
    output wire clkoutp,       // 54MHz 180-degree phase shifted for SDRAM
    output wire lock           // PLL locked indicator
);

    // Gowin rPLL instantiation
    // IDIV=1, FBDIV=2 gives 27*2/1 = 54MHz
    rPLL #(
        .FCLKIN("27"),           // Input frequency in MHz
        .IDIV_SEL(0),            // IDIV = 1 (IDIV_SEL + 1)
        .FBDIV_SEL(1),           // FBDIV = 2 (FBDIV_SEL + 1)
        .ODIV_SEL(8),            // ODIV = 8, gives VCO/8 output
        .DYN_SDIV_SEL(2),        // Not used for phase shift
        .PSDA_SEL("0000"),       // Phase shift for clkoutp
        .DUTYDA_SEL("1000"),     // 50% duty cycle
        .DYN_DA_EN("FALSE"),     // Static configuration
        .CLKOUT_FT_DIR(1'b1),    // Fine tune direction
        .CLKOUTP_FT_DIR(1'b1),
        .CLKOUT_DLY_STEP(0),
        .CLKOUTP_DLY_STEP(0),
        .CLKFB_SEL("internal"),  // Internal feedback
        .CLKOUT_BYPASS("false"),
        .CLKOUTP_BYPASS("false"),
        .CLKOUTD_BYPASS("false"),
        .DEVICE("GW2AR-18C")
    ) pll_inst (
        .CLKIN(clkin),
        .CLKFB(1'b0),            // Not used with internal feedback
        .RESET(1'b0),
        .RESET_P(1'b0),
        .FBDSEL(6'b0),
        .IDSEL(6'b0),
        .ODSEL(6'b0),
        .PSDA(4'b0),
        .DUTYDA(4'b0),
        .FDLY(4'b0),
        .CLKOUT(clkout),
        .CLKOUTP(clkoutp),       // 180-degree phase shifted
        .CLKOUTD(),
        .CLKOUTD3(),
        .LOCK(lock)
    );

endmodule
