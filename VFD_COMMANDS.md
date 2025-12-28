# Noritake GU256x128C VFD Command Reference

Quick reference for programming the GU256x128C VFD display.

## Communication Protocol

**Parallel Interface (8-bit):**
- Data bus: 8-bit parallel (D0-D7)
- Write strobe: WR (active low)
- Ready signal: READY (from VFD, high when ready to receive)
- Voltage: 5V logic (use level shifters with 3.3V FPGA)

**Timing:**
1. Wait for READY = HIGH
2. Place data on bus
3. Assert WR = LOW
4. Hold for minimum pulse width (~500ns)
5. Release WR = HIGH
6. Wait for READY before next byte

## Basic Commands

### Display Control

| Command | Hex  | Description |
|---------|------|-------------|
| Clear   | 0x0C | Clear display, cursor to home |
| Home    | 0x01 | Cursor to home position |
| Backspace | 0x08 | Move cursor back one position |
| Cursor Right | 0x09 | Move cursor right (tab) |
| Line Feed | 0x0A | Move cursor down one line |
| Carriage Return | 0x0D | Move cursor to start of line |

### Text Mode Commands

```verilog
// Write text
data_bus <= "H";  // Write character 'H'
// or
data_bus <= 8'h48;  // ASCII 'H'
```

### Graphics Mode Commands

#### Enter Graphics Mode
```verilog
// 1. Send graphics mode command
data_bus <= 8'h02;  // Enter graphics mode
```

#### Graphics Write Command
```verilog
// 2. Graphics write sequence
data_bus <= 8'h47;  // 'G' - Graphics write command

// 3. X position (2 bytes, little endian)
data_bus <= x_pos[7:0];    // X low byte
data_bus <= x_pos[15:8];   // X high byte

// 4. Y position (1 byte)
data_bus <= y_pos[7:0];    // Y position (0-127)

// 5. Width (2 bytes, little endian)
data_bus <= width[7:0];    // Width low byte
data_bus <= width[15:8];   // Width high byte

// 6. Height (1 byte)
data_bus <= height[7:0];   // Height (1-128)

// 7. Pixel data (width * height / 8 bytes)
// Data format: 8 pixels per byte, LSB first
// Row by row, left to right
```

### Brightness Control

```verilog
// Set brightness (0-255)
data_bus <= 8'h04;         // Brightness command
data_bus <= 8'h80;         // 50% brightness (0x00-0xFF)
```

### Cursor Control

```verilog
// Set cursor position
data_bus <= 8'h1B;         // ESC
data_bus <= 8'h48;         // 'H' - cursor position
data_bus <= x_pos;         // Column (0-31 for text)
data_bus <= y_pos;         // Row (0-15 for text)
```

## Graphics Data Format

### Pixel Packing
- 8 pixels per byte
- LSB = leftmost pixel
- MSB = rightmost pixel
- Bit value: 1 = ON, 0 = OFF

**Example:**
```
Byte 0xAA = 10101010 binary
Displays as: □■□■□■□■ (alternating pixels)
```

### Image Organization
```
Row 0: [byte 0][byte 1][byte 2]...[byte 31]  (256 pixels / 8)
Row 1: [byte 32][byte 33]...
...
Row 127: [byte 4064][byte 4065]...[byte 4095]

Total: 256 × 128 / 8 = 4096 bytes
```

## Common Patterns

### Initialize Display
```verilog
// Recommended startup sequence
1. Wait ~100ms after power-on
2. Send 0x0C (clear display)
3. Send 0x04 0xFF (max brightness)
4. Begin normal operation
```

### Write String
```verilog
// Example: "HELLO"
data_bus <= "H"; wait_and_pulse_wr();
data_bus <= "E"; wait_and_pulse_wr();
data_bus <= "L"; wait_and_pulse_wr();
data_bus <= "L"; wait_and_pulse_wr();
data_bus <= "O"; wait_and_pulse_wr();
```

### Draw Full Screen Image
```verilog
1. Send: 0x02           (graphics mode)
2. Send: 0x47           (graphics write)
3. Send: 0x00, 0x00     (X = 0)
4. Send: 0x00           (Y = 0)
5. Send: 0x00, 0x01     (Width = 256)
6. Send: 0x80           (Height = 128)
7. Send: 4096 bytes     (pixel data)
```

### Draw Partial Image (Example: 64×32 at position 50,20)
```verilog
1. Send: 0x02           (graphics mode)
2. Send: 0x47           (graphics write)
3. Send: 0x32, 0x00     (X = 50)
4. Send: 0x14           (Y = 20)
5. Send: 0x40, 0x00     (Width = 64)
6. Send: 0x20           (Height = 32)
7. Send: 256 bytes      (64 × 32 / 8)
```

## Troubleshooting

### Display Not Responding
- ✓ Check level shifters (FPGA is 3.3V, VFD is 5V)
- ✓ Verify READY signal is working
- ✓ Ensure WR pulse is long enough (>500ns)
- ✓ Check power supply (5V for VFD)

### Characters Work, Graphics Don't
- ✓ Verify graphics mode command (0x02) is sent first
- ✓ Check all 8 parameters are sent before pixel data
- ✓ Ensure pixel data is in correct format (8 pixels/byte)
- ✓ Verify byte count matches (width × height / 8)

### Image Appears Corrupted
- ✓ Check pixel packing (LSB = leftmost)
- ✓ Verify width/height parameters are correct
- ✓ Ensure data is sent row-by-row, left-to-right
- ✓ Check for timing issues (wait for READY)

### Timing Issues
- ✓ WR pulse too short: increase hold time
- ✓ Not waiting for READY: add state machine delays
- ✓ Clock too fast: add counter-based delays

## Example FSM States

```verilog
STATE_IDLE          -> Wait for start trigger
STATE_WAIT_READY    -> Wait for VFD READY signal
STATE_SEND_DATA     -> Put data on bus
STATE_PULSE_WR      -> Assert WR signal (hold ~5 clocks at 27MHz)
STATE_RELEASE_WR    -> Release WR signal
STATE_NEXT_BYTE     -> Increment address/counter
```

## Useful Constants

```verilog
// Display dimensions
parameter DISPLAY_WIDTH  = 256;
parameter DISPLAY_HEIGHT = 128;
parameter DISPLAY_BYTES  = (DISPLAY_WIDTH * DISPLAY_HEIGHT) / 8;  // 4096

// Character mode (8×16 font)
parameter CHAR_WIDTH  = 8;
parameter CHAR_HEIGHT = 16;
parameter CHAR_COLS   = DISPLAY_WIDTH / CHAR_WIDTH;    // 32
parameter CHAR_ROWS   = DISPLAY_HEIGHT / CHAR_HEIGHT;  // 8

// Timing (at 27 MHz clock)
parameter WR_PULSE_CLOCKS = 5;      // ~185ns WR pulse
parameter READY_TIMEOUT   = 27000;  // 1ms timeout
```

## References

- GU256x128C-803B Datasheet: [Noritake](https://www.noritake-elec.com/)
- This project: See `vfd_graphics_writer.v` for complete implementation
- Character writer: See `test_write.v` for working example
