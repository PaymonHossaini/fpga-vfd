# Complete VS Code Workflow for Tang Nano 20K

## Quick Reference Card

### 🎯 First Time Setup

1. **Install extensions** (VS Code will prompt automatically):
   - Verilog-HDL/SystemVerilog
   - TerosHDL

2. **Install tools**:
   ```bash
   # Install Gowin EDA (download from gowinsemi.com)
   export GOWIN_HOME="/path/to/Gowin"
   export PATH="$GOWIN_HOME/IDE/bin:$PATH"
   
   # Install openFPGALoader
   sudo apt install openFPGALoader
   # or: brew install openfpgaloader (macOS)
   
   # Install Python dependencies
   pip3 install Pillow
   ```

3. **Verify installation**:
   ```bash
   make check-tools
   ```

---

## 📝 Daily Development Workflow

### Working with Characters (Already Working!)

Your current `test_write.v` module handles character display perfectly.

### Adding Images (New!)

#### Option 1: Use Test Pattern
```bash
# 1. Generate pattern
make test-pattern

# 2. Convert to Verilog
make image-rom IMAGE=test_pattern.png

# 3. Build and flash
make flash
```

#### Option 2: Use Your Own Image
```bash
# 1. Prepare your image (any format, will be converted)
# 2. Convert to Verilog ROM
make image-rom IMAGE=my_logo.png

# 3. Build and program
make flash
```

#### Option 3: Manual Steps
```bash
# Create test image
cd scripts
./create_test_pattern.py my_test.png grid

# Convert to Verilog
./image_to_verilog.py my_test.png ../src/image_rom.v

# Return to project root
cd ..

# Build and program
make flash
```

---

## ⌨️ VS Code Keyboard Shortcuts

| Action | Shortcut | Command |
|--------|----------|---------|
| **Build** | `Ctrl+Shift+B` | Synthesize project |
| **Program FPGA** | `Ctrl+Shift+P` → "Run Task" → "Program FPGA" | Flash bitstream |
| **Open Terminal** | `Ctrl+~` | Integrated terminal |
| **Command Palette** | `Ctrl+Shift+P` | Access all commands |
| **Go to File** | `Ctrl+P` | Quick file navigation |
| **Search in Files** | `Ctrl+Shift+F` | Search project |

---

## 🏗️ Project Files Overview

```
fpga-vfd/
├── 📄 Makefile                     ← Command-line build system
├── 📄 fpga_2_vfd.gprj              ← Gowin project file
│
├── 📁 src/
│   ├── top.v                       ← Your current top module
│   ├── test_write.v                ← Character writer (working!)
│   ├── vfd_graphics_writer.v       ← Graphics writer (new!)
│   ├── top_example_with_graphics.v ← Integration example
│   ├── image_rom.v                 ← Generated from images
│   └── vfd_parallel_interface.cst  ← Pin constraints
│
├── 📁 scripts/
│   ├── image_to_verilog.py         ← Image converter
│   └── create_test_pattern.py      ← Test pattern generator
│
├── 📁 .vscode/
│   ├── tasks.json                  ← Build tasks
│   ├── settings.json               ← Editor settings
│   └── extensions.json             ← Recommended extensions
│
└── 📁 impl/                        ← Build outputs (generated)
    └── pnr/fpga_2_vfd.fs           ← Bitstream file
```

---

## 🔧 Common Tasks

### Build Project
**VS Code:** `Ctrl+Shift+B`  
**Terminal:** `make build`

### Program FPGA
**VS Code:** Command Palette → "Run Task" → "Program FPGA"  
**Terminal:** `make program`

### Build + Program
**Terminal:** `make flash`

### View Build Reports
```bash
make report     # Full report
make resources  # Resource usage
make timing     # Timing summary
```

### Clean Build
```bash
make clean
```

---

## 🎨 Image Workflow Details

### 1. Prepare Image
- Any image format (PNG, JPEG, etc.)
- Will be converted to 256×128 monochrome
- Higher contrast works better

### 2. Convert to Verilog
```bash
./scripts/image_to_verilog.py input.png src/image_rom.v
```

This generates a Verilog ROM module:
```verilog
module image_rom (
    input  [14:0] addr,   // 0 to 4095
    output [7:0]  data    // 8 pixels per byte
);
```

### 3. Integrate into Design

**Option A:** Use provided example
- Copy `top_example_with_graphics.v` → `top.v`
- Includes button-triggered image display

**Option B:** Modify your existing `top.v`
```verilog
// Add graphics writer instance
vfd_graphics_writer gfx_writer (
    .clk(clk),
    .rst(1'b0),
    .start(trigger_signal),
    .ready(ready),
    .data_bus(gfx_data_bus),
    .wr_n(gfx_wr_n),
    .busy(gfx_busy),
    .done(gfx_done)
);
```

---

## 🐛 Troubleshooting

### "gw_sh: command not found"
```bash
# Add to ~/.bashrc or ~/.zshrc
export GOWIN_HOME="/path/to/Gowin_V1.9.x"
export PATH="$GOWIN_HOME/IDE/bin:$PATH"
source ~/.bashrc
```

### "openFPGALoader: command not found"
```bash
# Ubuntu/Debian
sudo apt install openFPGALoader

# Or build from source
git clone https://github.com/trabucayre/openFPGALoader.git
cd openFPGALoader && mkdir build && cd build
cmake .. && make && sudo make install
```

### FPGA not detected
```bash
# Check USB permissions
sudo usermod -a -G plugdev $USER
# Log out and back in

# Test detection
openFPGALoader --detect
```

### Display shows garbage
- Check level shifters (3.3V ↔ 5V)
- Verify READY signal timing
- Check WR pulse width (see `VFD_COMMANDS.md`)

### Image doesn't appear
- Ensure `image_rom.v` is in project
- Check module instantiation in graphics writer
- Verify graphics command sequence (see `VFD_COMMANDS.md`)

---

## 📚 Documentation Files

- [README.md](README.md) - Project overview
- [VSCODE_SETUP.md](VSCODE_SETUP.md) - Detailed VS Code setup
- [VFD_COMMANDS.md](VFD_COMMANDS.md) - Complete VFD command reference
- [scripts/README.md](scripts/README.md) - Image conversion tools
- This file - Quick reference workflow

---

## 🎓 Learning Path

### Level 1: Character Display ✅
You're here! Characters work perfectly.

### Level 2: Static Images (Next)
1. Generate test pattern: `make test-pattern`
2. Convert to ROM: `make image-rom IMAGE=test_pattern.png`
3. Use example: `src/top_example_with_graphics.v`
4. Build and test: `make flash`

### Level 3: Dynamic Images (Future)
- Multiple images in ROM
- Image selection logic
- Animations (frame by frame)
- Real-time graphics generation

### Level 4: Advanced (Future)
- Text overlay on graphics
- Partial screen updates
- Scrolling and transitions
- External image sources (SD card, etc.)

---

## 💡 Tips

1. **Start Simple**: Use test patterns first, then move to custom images
2. **Use LEDs**: Your LED indicators are perfect for debugging FSM states
3. **Check Timing**: VFD needs proper timing - see LED ready state
4. **Incremental Changes**: Test after each modification
5. **Save Often**: Git commits after each working milestone

---

## 🚀 Next Steps

1. **Try the test pattern**:
   ```bash
   make test-pattern
   make image-rom IMAGE=test_pattern.png
   # Edit fpga_2_vfd.gprj to include vfd_graphics_writer.v
   make flash
   ```

2. **Integrate with your code**:
   - See `top_example_with_graphics.v` for reference
   - Copy relevant parts to your `top.v`

3. **Experiment**:
   - Try different images
   - Adjust timing parameters
   - Add more features

---

## 📞 Resources

- **Tang Nano 20K**: https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/
- **GU256x128C Datasheet**: https://www.noritake-elec.com/
- **openFPGALoader**: https://github.com/trabucayre/openFPGALoader
- **Gowin Tools**: https://www.gowinsemi.com/en/support/download_eda/

---

**Happy FPGA Development! 🎉**


**Papers/resources
