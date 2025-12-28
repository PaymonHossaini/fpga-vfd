#!/bin/bash
# VFD Image Display Build Script
# Usage: ./build_image.sh [image.bmp]
# If image provided, converts it first then builds and programs

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Convert image if provided
if [ -n "$1" ]; then
    echo "=== Converting image: $1 ==="
    python3 bmp_to_vfd_rom.py "$1" src/vfd_image_rom.v
    echo ""
fi

echo "=== Building vfd_image_display ==="

# Synthesize (needs both ROM and display modules)
echo ">>> Yosys synthesis..."
yosys -q -p "read_verilog src/vfd_image_rom.v src/vfd_image_display.v; synth_gowin -top vfd_image_display -json vfd_image_display.json"

# Place and route
echo ">>> NextPNR place & route..."
~/nextpnr/build/nextpnr-himbaechel \
    --device GW2AR-LV18QN88C8/I7 \
    --vopt family=GW2A-18C \
    --vopt cst=src/vfd_graphics_test.cst \
    --json vfd_image_display.json \
    --write vfd_image_display_pnr.json 2>&1 | tail -5

# Pack bitstream
echo ">>> Gowin pack..."
~/.local/bin/gowin_pack -d GW2AR-LV18QN88C8/I7 -o vfd_image_display.fs vfd_image_display_pnr.json

# Program FPGA
echo ">>> Programming FPGA..."
openFPGALoader -b tangnano20k vfd_image_display.fs

echo ""
echo "=== Done! Power cycle the VFD display to see the image ==="
