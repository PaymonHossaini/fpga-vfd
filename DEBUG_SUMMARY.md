# VFD Graphics Debug Summary

## Project Goal
Display bitmap images on a **Noritake GU256x128C-3900B** VFD (256×128 pixels) using a **Tang Nano 20K FPGA** with an 8-bit parallel interface.

## What's Working
- **Toolchain**: Open-source flow is fully functional
  - `yosys` → `nextpnr-himbaechel` → `gowin_pack` → `openFPGALoader`
  - Build script: `./build.sh <filename>.v` (auto-looks in src/)
- **LED blink test**: Confirmed FPGA programming works
- **Text display**: "Hello" text works at 4.95V logic level
- **Graphics command recognized**: Display shows pixels (not text characters) when graphics command is properly received

## Hardware Setup
- **FPGA**: Tang Nano 20K (GW2AR-LV18QN88C8/I7, aka GW2A-18C)
- **Display**: Noritake GU256x128C-3900B (VFD, 8-bit parallel)
- **Logic Level**: 4.95V required for reliable operation
- **Pin Constraints**: [src/vfd_graphics_test.cst](src/vfd_graphics_test.cst)
  - `data_bus[0:7]` on pins 25, 53, 71, 72, 41, 42, 80, 76
  - `wr_n` (active low write) on pin 74
  - `ready` signal on pin 51

## Graphics Command Format
Real-time bit image display command (Section 4.7.4.32 of datasheet):
```
1Fh 28h 66h 11h xL xH yL yH g d(1)...d(k)
```
- `x` = width in pixels (e.g., 16 for 16px wide)
- `y` = height in **8-dot units** (e.g., 2 for 16px tall)
- `g` = 1 (display immediately)
- `k` = x × y × g bytes of image data

## Key Discoveries

### 1. Receive Buffer Persistence Problem
**Critical finding**: The VFD's receive buffer persists across FPGA reprogramming!

When you reprogram the FPGA, leftover bytes from the previous run remain in the display's command buffer. This causes:
- Random character display instead of graphics
- Inconsistent behavior between runs (cycles through 2-3 different outputs)

**Solution**: Send 64 null bytes (0x00) before any commands to flush partial command sequences.

### 2. Initialize Command Does NOT Clear Buffer
From datasheet section 4.7.4.2:
> "Contents of receive buffer remain in memory"

The `ESC @` (1Bh 40h) initialize command resets display settings but does NOT clear the receive buffer.

### 3. Bit Ordering (NEEDS VERIFICATION)
Based on datasheet memory diagram (Section 4.2.1):
- **D0 = top pixel** (y=0)
- **D7 = bottom pixel** (y=7)

This is the OPPOSITE of typical conventions. The diagram shows:
```
D7  (bottom of 8-pixel segment)
D6
D5
D4
D3
D2
D1
D0  y=0 (top of 8-pixel segment)
```

### 4. Data Ordering for 16x16 Image
For a 16×16 image (32 bytes total):
- Data is sent **column by column**, left to right
- Each column has 2 bytes: top 8 pixels first, then bottom 8 pixels
- Byte order: col0-top, col0-bot, col1-top, col1-bot, ... col15-top, col15-bot

## Current Test Pattern (v29)
16×16 box outline with:
- Left edge (column 0): 0xFF, 0xFF (all pixels on)
- Middle columns (1-14): 0x01, 0x80 (top and bottom edges only)
- Right edge (column 15): 0xFF, 0xFF (all pixels on)

## Timing Parameters Used
- 100ms startup delay
- 30ms delay after init (1Bh 40h) and clear (0Ch) commands
- 1ms delay between other bytes
- ~2µs write pulse width (54 clock cycles at 27MHz)

## Arduino Library Reference
Located at: [Noritake_VFD_GU3000/src/](Noritake_VFD_GU3000/src/)

Key file: `Noritake_VFD_GU3000.cpp`

### GU3000_drawImage Implementation (line 371):
```cpp
void Noritake_VFD_GU3000::GU3000_drawImage(unsigned width, uint8_t height, const uint8_t *data) {
    us_command('f', 0x11);        // Sends 1F 28 66 11
    command_xy(width, height);    // width_L, width_H, height/8_L, height/8_H
    command((uint8_t) 1);         // g = 1
    for (unsigned i = 0; i<(height/8)*width; i++)
        command(data[i]);
}
```

**Note**: The library passes height in **pixels** and divides by 8 internally.

### GU3000_init Implementation (line ~285):
```cpp
void Noritake_VFD_GU3000::GU3000_init() {
    command(0x1b);
    command(0x40);  // ESC @ - Initialize
}
```

## Outstanding Issues

### 1. Display Reset Inconsistency
Even with null byte flushing, the display sometimes shows inconsistent results between runs. The Arduino library may have additional initialization that we're missing.

**Investigate in Arduino code:**
- How does the library handle startup/reset?
- Is there a hardware reset pin being used?
- What delays are used after initialization?

### 2. Box Pattern Not Perfect
v28/v29 show a box-like pattern but with issues:
- Some columns may be flipped
- Missing pixels on edges
- Pattern may be shifted

## Files Reference
- Latest working Verilog: [src/vfd_graphics_v29.v](src/vfd_graphics_v29.v)
- Pin constraints: [src/vfd_graphics_test.cst](src/vfd_graphics_test.cst)
- Datasheet (markdown): [GU-3900B_Software_Specification.md](GU-3900B_Software_Specification.md)
- Arduino library: [Noritake_VFD_GU3000/src/](Noritake_VFD_GU3000/src/)

## Next Steps to Try
1. Study Arduino library's full initialization sequence
2. Check if there's a hardware reset pin that should be toggled
3. Try the simpler `GU3000_dot()` command to draw individual pixels
4. Use the `GU3000_shape()` command to draw a rectangle (may be more reliable)
5. Consider using serial interface instead of parallel (Arduino lib has serial code)

## Build Commands
```bash
# Quick build and program
./build.sh vfd_graphics_v29.v

# Manual build steps
cd src
unset LD_LIBRARY_PATH
yosys -p "read_verilog FILE.v; synth_gowin -top MODULE -json FILE.json"
~/nextpnr/build/nextpnr-himbaechel --device GW2AR-LV18QN88C8/I7 --vopt family=GW2A-18C --vopt cst=vfd_graphics_test.cst --json FILE.json --write FILE_pnr.json
~/.local/bin/gowin_pack -d GW2AR-LV18QN88C8/I7 -o FILE.fs FILE_pnr.json
openFPGALoader -b tangnano20k FILE.fs
```
