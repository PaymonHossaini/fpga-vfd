#!/bin/bash
# VFD FPGA Build Script
# Usage: ./build.sh <verilog_file> [top_module]
# Example: ./build.sh vfd_graphics_v26.v
#          ./build.sh vfd_graphics_v26.v vfd_graphics_v26

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <verilog_file> [top_module] [cst_file]"
    echo "Example: $0 src/vfd_graphics_v26.v"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Handle relative paths from where the user ran the command
if [[ "$1" == /* ]]; then
    VERILOG_FILE="$1"
else
    VERILOG_FILE="$SCRIPT_DIR/src/$1"
fi

BASENAME=$(basename "$VERILOG_FILE" .v)
TOP_MODULE="${2:-$BASENAME}"
CST_FILE="${3:-$SCRIPT_DIR/src/vfd_graphics_test.cst}"

echo "=== Building $VERILOG_FILE (top: $TOP_MODULE) ==="

unset LD_LIBRARY_PATH

echo ">>> Yosys synthesis..."
yosys -q -p "read_verilog $VERILOG_FILE; synth_gowin -top $TOP_MODULE -json ${BASENAME}.json"

echo ">>> NextPNR place & route..."
~/nextpnr/build/nextpnr-himbaechel --device GW2AR-LV18QN88C8/I7 \
    --vopt family=GW2A-18C --vopt cst=$CST_FILE \
    --json ${BASENAME}.json --write ${BASENAME}_pnr.json 2>&1 | tail -5

echo ">>> Gowin pack..."
~/.local/bin/gowin_pack -d GW2AR-LV18QN88C8/I7 -o ${BASENAME}.fs ${BASENAME}_pnr.json

echo ">>> Programming FPGA..."
openFPGALoader -b tangnano20k ${BASENAME}.fs

echo "=== Done! ==="
