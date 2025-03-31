module top (
    // Parallel interface signals from/to the VFD
    input  wire ready,           // from VFD CN4 pin 12 via level shifter
    output wire wr_n,            // to VFD CN4 pin 10
    output wire [7:0] data_bus,  // to VFD CN4 pins 1-8

    // Onboard LED indicators
    output wire led,         // Master status LED
    output wire led_ready,   // Shows VFD READY state
    output wire led_state0,  // Lights in FSM state 0
    output wire led_state1   // Lights in FSM state 1
);

    // Internal 27 MHz oscillator (inferred from Tang Nano 20K)
    wire clk;
    Gowin_OSC osc_inst (
        .oscout(clk)
    );
    // No extra defparams needed if Gowin_OSC.v sets FREQ_DIV internally

    // Instantiate the VFD writer FSM
    vfd_test_writer writer (
        .clk(clk),
        .ready(ready),
        .data_bus(data_bus),
        .wr_n(wr_n),
        .led(led),
        .led_ready(led_ready),
        .led_state0(led_state0),
        .led_state1(led_state1)
    );

endmodule