# FPGA VFD Display Driver

Tang Nano 20K FPGA driver for the Noritake Itron GU256x128C VFD display.

## Features

✅ **Character display** - Write text to the VFD  
🚧 **Graphics mode** - Display bitmap images (in progress)  
🛠️ **VS Code integration** - Build and program directly from VS Code

## Hardware

- **FPGA**: Tang Nano 20K (Gowin GW2AR-18C)
- **Display**: Noritake Itron GU256x128C-803B (256×128 VFD)
- **Interface**: 8-bit parallel interface with READY/WR handshaking

## Quick Start

### 1. Setup Development Environment

See [VSCODE_SETUP.md](VSCODE_SETUP.md) for detailed VS Code configuration.

**Requirements:**
- Gowin EDA Toolchain
- openFPGALoader (for programming)
- Python 3 with Pillow (for image conversion)

### 2. Build and Program

**Using VS Code:**
- Build: `Ctrl+Shift+B`
- Program: `Ctrl+Shift+P` → "Tasks: Run Task" → "Gowin: Program FPGA"

**Using command line:**
```bash
# With Makefile (recommended)
make flash              # Build and program

# Or manually
gw_sh fpga_2_vfd.gprj
openFPGALoader -b tangnano20k impl/pnr/fpga_2_vfd.fs

# See all make targets
make help
```

## Project Structure

```
fpga-vfd/
├── src/
│   ├── top.v                    # Top-level module
│   ├── test_write.v             # Character writing FSM
│   ├── vfd_graphics_writer.v    # Graphics mode controller
│   └── gowin_osc/               # Internal oscillator IP
├── scripts/
│   ├── image_to_verilog.py      # Convert images to Verilog ROM
│   └── create_test_pattern.py   # Generate test patterns
├── impl/                        # Build outputs
└── .vscode/                     # VS Code configuration
```

## Working with Images

### Generate Test Pattern
```bash
cd scripts
./create_test_pattern.py test_grid.png
```

### Convert Image to Verilog
```bash
./image_to_verilog.py test_grid.png ../src/image_rom.v
```

### Use in Your Design
The `vfd_graphics_writer` module automatically instantiates the ROM and handles the display protocol.

See [scripts/README.md](scripts/README.md) for detailed usage.

## Pin Assignments

See [src/vfd_parallel_interface.cst](src/vfd_parallel_interface.cst) for complete pinout.

**Key connections:**
- `data_bus[7:0]` → VFD CN4 pins 1-8 (via level shifter)
- `wr_n` → VFD CN4 pin 10 (write strobe)
- `ready` → VFD CN4 pin 12 (VFD ready signal)

**Note**: The VFD operates at 5V. Use appropriate level shifters for the 3.3V FPGA I/O.

## Development with VS Code

This project is configured for VS Code development as an alternative to the Gowin IDE:

- Syntax highlighting with Verilog extensions
- Build tasks integrated with keyboard shortcuts
- One-click programming workflow
- Terminal-based development flow

See [VSCODE_SETUP.md](VSCODE_SETUP.md) for complete setup instructions.

## Resources

- [Tang Nano 20K Documentation](https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/nano-20k.html)
- [GU256x128C Datasheet](https://www.noritake-elec.com/products/model?part=GU256X128C-803B)
- [Gowin EDA Tools](https://www.gowinsemi.com/en/support/download_eda/)
- [openFPGALoader](https://github.com/trabucayre/openFPGALoader)

## License

See [LICENSE](LICENSE) for details.