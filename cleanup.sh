#!/bin/bash
# Cleanup script for fpga-vfd repository
# Removes development artifacts, keeping only essential files

set -e
cd "$(dirname "$0")"

echo "=== VFD FPGA Cleanup Script ==="
echo "This will remove development artifacts and keep only essential files."
echo ""

# Files to KEEP (essential for the project)
# - build.sh
# - src/vfd_image_display_simple.v (main working module)
# - src/vfd_image_display.v (original with UART debug)
# - src/vfd_image_rom_hex.v (ROM module)
# - src/vfd_image_rom.hex (image data)
# - src/vfd_graphics_test.cst (pin constraints)
# - src/uart_tx.v (for debugging)
# - src/gowin_osc/ (oscillator IP)
# - bmp_to_vfd_rom.py (image conversion)
# - Documentation: README.md, LICENSE, etc.

# Dry run by default - remove --dry-run to actually delete
DRY_RUN=1
if [ "$1" == "--delete" ]; then
    DRY_RUN=0
    echo "*** DELETING FILES ***"
else
    echo "*** DRY RUN - add --delete to actually remove files ***"
fi
echo ""

delete_file() {
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "Would delete: $1"
    else
        echo "Deleting: $1"
        rm -f "$1"
    fi
}

delete_dir() {
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "Would delete dir: $1"
    else
        echo "Deleting dir: $1"
        rm -rf "$1"
    fi
}

# === BUILD ARTIFACTS (root directory) ===
echo "--- Build artifacts (.json, .fs, _pnr.json) ---"
for f in *.json *.fs; do
    [ -f "$f" ] && delete_file "$f"
done

# === CAPTURED/DEBUG FILES ===
echo "--- Debug/capture files ---"
delete_file "captured_bytes.bin"
delete_file "captured_hex.txt"
delete_file "expected_hex.txt"
delete_file "expected_debug_pattern.png"
delete_file "reconstructed_image.png"
delete_file "rom_reconstructed.png"
delete_file "rom_reconstructed_inv.png"

# === OLD SOURCE FILES (src/) ===
echo "--- Old test/development source files ---"
# Keep only essential .v files
KEEP_V_FILES="vfd_image_display_simple.v vfd_image_display.v vfd_image_rom_hex.v uart_tx.v"

for f in src/*.v; do
    fname=$(basename "$f")
    keep=0
    for k in $KEEP_V_FILES; do
        [ "$fname" == "$k" ] && keep=1
    done
    [ "$keep" -eq 0 ] && delete_file "$f"
done

# === OLD CONSTRAINT FILES ===
echo "--- Old constraint files ---"
for f in src/*.cst; do
    fname=$(basename "$f")
    # Keep only vfd_graphics_test.cst
    [ "$fname" != "vfd_graphics_test.cst" ] && delete_file "$f"
done

# === BUILD ARTIFACTS IN SRC ===
echo "--- Build artifacts in src/ ---"
for f in src/*.json src/*.fs; do
    [ -f "$f" ] && delete_file "$f"
done

# === OLD HEX FILES (keep only vfd_image_rom.hex) ===
echo "--- Old hex files ---"
for f in src/*.hex; do
    fname=$(basename "$f")
    [ "$fname" != "vfd_image_rom.hex" ] && delete_file "$f"
done

# === IMAGE PREVIEWS IN SRC ===
echo "--- Image previews in src/ ---"
delete_file "src/vfd_image_rom_preview.png"
delete_file "src/vfd_image_rom_vfd_preview.bmp"

# === SDC FILES ===
delete_file "src/fpga_2_vfd.sdc"

# === OLD PROJECT FILES ===
echo "--- Old project files ---"
delete_file "fpga_2_vfd.gprj"
delete_file "fpga_2_vfd.gprj.user"
delete_file "led_blink_test.gprj"
delete_file "Makefile"
delete_file "setup.sh"

# === DEBUG DOCUMENTATION ===
echo "--- Debug documentation ---"
delete_file "DEBUG_SUMMARY.md"
delete_file "CHEATSHEET.txt"
delete_file "VFD_COMMANDS.md"
delete_file "VSCODE_SETUP.md"
delete_file "WORKFLOW.md"

# === IMPL DIRECTORY (Gowin IDE output) ===
echo "--- Gowin IDE output ---"
delete_dir "impl"

# === OLD SCRIPTS ===
echo "--- Old scripts ---"
delete_file "gen_dots.py"
delete_file "hex_to_image.py"
delete_file "verify_rom.py"
delete_file "build_image.sh"

# === TEST DIRECTORIES ===
echo "--- Test directories ---"
delete_dir "test"
delete_dir "scripts"
delete_dir "docs"

echo ""
echo "=== Summary ==="
echo "Essential files kept:"
echo "  - build.sh"
echo "  - src/vfd_image_display_simple.v"
echo "  - src/vfd_image_display.v" 
echo "  - src/vfd_image_rom_hex.v"
echo "  - src/vfd_image_rom.hex"
echo "  - src/vfd_graphics_test.cst"
echo "  - src/uart_tx.v"
echo "  - src/gowin_osc/"
echo "  - bmp_to_vfd_rom.py"
echo "  - README.md, LICENSE"
echo "  - GU-3900B_Software_Specification.md"
echo "  - images/, ImageDemo/, Noritake_VFD_GU3000/"
echo ""
if [ "$DRY_RUN" -eq 1 ]; then
    echo "Run with --delete to actually remove files"
fi
