#!/usr/bin/env python3
"""
Verify VFD ROM by reconstructing image from verilog file
"""
import re
from PIL import Image

def read_rom_data(verilog_file):
    """Parse verilog ROM file and extract byte data"""
    rom_data = [0] * 4096  # Default to 0
    
    with open(verilog_file, 'r') as f:
        content = f.read()
    
    # Find all case statements: 13'd1234: data = 8'hAB;
    pattern = r"13'd(\d+):\s*data\s*=\s*8'h([0-9A-Fa-f]{2});"
    matches = re.findall(pattern, content)
    
    for addr_str, val_str in matches:
        addr = int(addr_str)
        val = int(val_str, 16)
        if addr < 4096:
            rom_data[addr] = val
    
    print(f"Found {len(matches)} ROM entries")
    return rom_data

def reconstruct_image(rom_data, width=256, height=128):
    """Reconstruct image from VFD byte format"""
    img = Image.new('1', (width, height))
    
    for x in range(width):
        for y_byte in range(height // 8):
            addr = x * 16 + y_byte
            if addr < len(rom_data):
                byte_val = rom_data[addr]
                for bit in range(8):
                    y = y_byte * 8 + bit
                    # bit 7 = top pixel, bit 0 = bottom pixel
                    pixel_on = (byte_val >> (7 - bit)) & 1
                    # PIL: 0=black, 1=white
                    img.putpixel((x, y), pixel_on)
    
    return img

def main():
    rom_file = "src/vfd_image_rom.v"
    output_file = "rom_reconstructed.png"
    
    print(f"Reading ROM from {rom_file}...")
    rom_data = read_rom_data(rom_file)
    
    print(f"Non-zero bytes: {sum(1 for b in rom_data if b != 0)}")
    
    # Print first 32 bytes to verify
    print("First 32 bytes:")
    for i in range(32):
        print(f"  [{i}] = 0x{rom_data[i]:02X}")
    
    print(f"\nReconstructing image...")
    img = reconstruct_image(rom_data)
    img.save(output_file)
    print(f"Saved to {output_file}")
    
    # Also save inverted for comparison
    img_inv = Image.new('1', (256, 128))
    for x in range(256):
        for y in range(128):
            img_inv.putpixel((x, y), 1 - img.getpixel((x, y)))
    img_inv.save("rom_reconstructed_inv.png")
    print("Saved inverted to rom_reconstructed_inv.png")

if __name__ == "__main__":
    main()
