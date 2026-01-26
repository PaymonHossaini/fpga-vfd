#!/bin/bash
# VFD FPGA Build Script
# Usage: ./build.sh [--capture] <verilog_file.v> [additional_files.v ...]
# Example: ./build.sh src/bus_test.v
#          ./build.sh src/vfd_image_display.v src/vfd_image_rom.v
#          ./build.sh --capture src/vfd_image_display.v src/vfd_image_rom.v src/uart_tx.v

set -e

# Check for --capture flag
CAPTURE=0
if [ "$1" == "--capture" ]; then
    CAPTURE=1
    shift
fi

if [ -z "$1" ]; then
    echo "Usage: $0 [--capture] <verilog_file.v> [additional_files.v ...]"
    echo "Example: $0 src/bus_test.v"
    echo "         $0 --capture src/vfd_image_display.v src/vfd_image_rom.v src/uart_tx.v"
    exit 1
fi

cd "$(dirname "$0")"

BASENAME=$(basename "$1" .v)
FILES="$@"

echo "=== Building $BASENAME ==="

yosys -q -p "read_verilog $FILES; synth_gowin -top vfd_image_display -json ${BASENAME}.json"
~/nextpnr/build/nextpnr-himbaechel --device GW2AR-LV18QN88C8/I7 --vopt family=GW2A-18C --vopt cst=src/vfd_graphics_test.cst --json ${BASENAME}.json --write ${BASENAME}_pnr.json 2>&1 | tail -3
~/.local/bin/gowin_pack -d GW2AR-LV18QN88C8/I7 -o ${BASENAME}.fs ${BASENAME}_pnr.json
openFPGALoader -b tangnano20k ${BASENAME}.fs

echo "=== Done! ==="

if [ "$CAPTURE" -eq 1 ]; then
    echo "=== Capturing UART (10s timeout)... ==="
    stty -F /dev/ttyUSB1 115200 raw -echo
    timeout 10 cat /dev/ttyUSB1 > captured_bytes.bin || true
    BYTES=$(wc -c < captured_bytes.bin)
    echo "=== Captured $BYTES bytes ==="
    if [ "$BYTES" -gt 0 ]; then
        xxd captured_bytes.bin | head -8
    fi
fi
