# Scripts Directory

Utility scripts for working with the VFD display.

## Scripts

### `image_to_verilog.py`
Converts image files to Verilog ROM modules for displaying on the VFD.

**Usage:**
```bash
./image_to_verilog.py input_image.png src/image_rom.v
```

**Features:**
- Converts any image format to 256x128 monochrome
- Generates synthesizable Verilog ROM module
- Packs 8 pixels per byte for efficiency

**Example workflow:**
```bash
# Create a test pattern
./create_test_pattern.py test_grid.png

# Convert to Verilog ROM
./image_to_verilog.py test_grid.png ../src/image_rom.v

# The image_rom module can now be used in your design
```

### `create_test_pattern.py`
Generates test patterns for verifying the display.

**Usage:**
```bash
# Create grid pattern (default)
./create_test_pattern.py test_grid.png

# Create checkerboard
./create_test_pattern.py test_checker.png checker
```

**Pattern types:**
- `grid`: Border, grid lines, diagonals, and text
- `checker`: Simple checkerboard pattern

## Requirements

Install Python dependencies:
```bash
pip3 install Pillow
```

## Workflow for Adding Images

1. **Prepare your image** (or create a test pattern):
   ```bash
   ./create_test_pattern.py my_test.png
   # Or use your own image
   ```

2. **Convert to Verilog ROM**:
   ```bash
   ./image_to_verilog.py my_test.png ../src/image_rom.v
   ```

3. **Update your project** to instantiate the graphics writer:
   - See `src/vfd_graphics_writer.v` for the display controller
   - The ROM will be automatically instantiated within the graphics writer

4. **Rebuild and program**:
   ```bash
   # In VS Code: Ctrl+Shift+B
   # Or from terminal:
   cd ..
   gw_sh fpga_2_vfd.gprj
   openFPGALoader -b tangnano20k impl/pnr/fpga_2_vfd.fs
   ```

## VFD Display Notes

The Noritake GU256x128C accepts graphics data in the following format:
- Resolution: 256×128 pixels
- Data format: 8 pixels per byte
- Command sequence:
  1. `0x02` - Enter graphics mode
  2. `0x47` - Graphics write command
  3. Position and size parameters
  4. Pixel data (row by row, left to right)

See `vfd_graphics_writer.v` for the full implementation.
