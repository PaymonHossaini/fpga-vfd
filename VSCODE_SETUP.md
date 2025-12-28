# VS Code Setup for Tang Nano 20K Development

## Overview
This guide will help you set up VS Code to replace the Gowin IDE for FPGA development with the Tang Nano 20K.

## 1. Install Required Software

### A. Gowin EDA Toolchain
Download and install from: https://www.gowinsemi.com/en/support/download_eda/

After installation, add Gowin tools to your PATH:
```bash
# Add to ~/.bashrc or ~/.zshrc
export GOWIN_HOME="/path/to/Gowin_V1.9.x"  # Adjust version
export PATH="$GOWIN_HOME/IDE/bin:$PATH"
```

### B. openFPGALoader (Recommended)
For programming the Tang Nano 20K directly from command line:
```bash
# On Ubuntu/Debian
sudo apt install openFPGALoader

# Or build from source
git clone https://github.com/trabucayre/openFPGALoader.git
cd openFPGALoader
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install
```

## 2. VS Code Extensions

Install these extensions (already configured in .vscode/extensions.json):
- **Verilog-HDL/SystemVerilog** (mshr-h.veriloghdl) - Syntax highlighting, linting
- **TerosHDL** (teros-technology.teroshdl) - Advanced HDL features, documentation

## 3. Using VS Code for Development

### Build Your Project
Press `Ctrl+Shift+B` or:
1. Open Command Palette (`Ctrl+Shift+P`)
2. Type "Tasks: Run Build Task"
3. Select "Gowin: Synthesize"

### Program Your FPGA
1. Open Command Palette (`Ctrl+Shift+P`)
2. Type "Tasks: Run Task"
3. Select "Gowin: Program FPGA"

### Build and Program in One Step
1. Open Command Palette (`Ctrl+Shift+P`)
2. Type "Tasks: Run Task"
3. Select "Gowin: Build and Program"

## 4. Alternative: Using Gowin Command Line

If openFPGALoader doesn't work, use Gowin's programmer:
```bash
# Synthesize project
gw_sh fpga_2_vfd.gprj

# Program FPGA (using Gowin Programmer)
programmer_cli -d GW2AR-18C -f impl/pnr/fpga_2_vfd.fs
```

## 5. Working with Images on the GU256x128C VFD

### Understanding the Display
- Resolution: 256x128 pixels
- Parallel interface: 8-bit data bus
- Commands: Mix of text and graphics modes

### Image Data Preparation
For displaying images, you need to:

1. **Convert image to proper format**:
   - Monochrome bitmap
   - 256x128 resolution
   - Binary format (1 bit per pixel)

2. **Generate Verilog ROM**:
```python
# Python script to convert image to Verilog memory
from PIL import Image

def image_to_verilog_mem(image_path, output_path):
    img = Image.open(image_path).convert('1')  # Convert to 1-bit
    img = img.resize((256, 128))
    
    with open(output_path, 'w') as f:
        f.write('// Image ROM for VFD Display\n')
        f.write('module image_rom(\n')
        f.write('    input [14:0] addr,  // 256*128 = 32768 pixels\n')
        f.write('    output reg data\n')
        f.write(');\n')
        f.write('    always @(*) begin\n')
        f.write('        case(addr)\n')
        
        pixels = list(img.getdata())
        for i, pixel in enumerate(pixels):
            if i % 8 == 0:  # Pack 8 pixels per byte
                byte_val = 0
                for j in range(8):
                    if i + j < len(pixels):
                        byte_val |= (1 if pixels[i+j] else 0) << j
                f.write(f"            15'd{i//8}: data = 8'h{byte_val:02X};\n")
        
        f.write('            default: data = 8\'h00;\n')
        f.write('        endcase\n')
        f.write('    end\n')
        f.write('endmodule\n')

# Usage
image_to_verilog_mem('my_image.png', 'src/image_rom.v')
```

3. **VFD Graphics Commands**:
The GU256x128C uses specific commands for graphics mode:
   - `0x02`: Graphics mode
   - `0x47`: Graphics Write command
   - Write pixel data row by row

### Example Graphics Module
```verilog
// Add graphics writing capability to your FSM
module vfd_graphics_writer(
    input wire clk,
    input wire ready,
    output reg [7:0] data_bus,
    output reg wr_n
);
    // FSM states for graphics mode
    // 1. Send 0x02 (graphics mode)
    // 2. Send 0x47 (graphics write)
    // 3. Stream pixel data from ROM
    // 4. Handle ready signal properly
endmodule
```

## 6. Tips for VS Code Development

### Terminal Commands
Use the integrated terminal (`Ctrl+~`) for:
```bash
# View synthesis reports
cat impl/gwsynthesis/fpga_2_vfd.rpt.html | lynx -stdin

# Monitor timing
cat impl/pnr/fpga_2_vfd.rpt.txt

# Check resource usage
grep -A 20 "Device Utilization" impl/pnr/fpga_2_vfd.rpt.txt
```

### Debugging
- Use LED indicators to debug FSM states
- Monitor signals with the Tang Nano's onboard LEDs
- Consider adding UART debug output for complex issues

## 7. Project Structure Best Practices

```
fpga-vfd/
├── .vscode/
│   ├── tasks.json          # Build and program tasks
│   └── settings.json       # Editor settings
├── src/
│   ├── top.v              # Top-level module
│   ├── vfd_controller.v   # VFD interface logic
│   ├── image_rom.v        # Image data ROM
│   └── *.cst              # Pin constraints
├── sim/                   # Testbenches (add later)
├── scripts/               # Python utilities
└── fpga_2_vfd.gprj       # Gowin project file
```

## Need Help?

Common issues:
1. **"gw_sh not found"** - Add Gowin tools to PATH
2. **Programming fails** - Check USB permissions (`sudo usermod -a -G plugdev $USER`)
3. **Display not responding** - Verify level shifters and timing signals

Happy coding! 🚀
