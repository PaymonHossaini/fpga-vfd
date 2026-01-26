#!/usr/bin/env python3
"""Convert vfd_image_rom.hex back to a PNG image to validate data integrity."""

from PIL import Image

# VFD display is 256x128, 1 bit per pixel
# 256 * 128 / 8 = 4096 bytes
WIDTH = 256
HEIGHT = 128

def hex_to_image(hex_file, output_file):
    # Read hex values
    with open(hex_file, 'r') as f:
        hex_values = [int(line.strip(), 16) for line in f if line.strip()]
    
    print(f"Read {len(hex_values)} bytes from {hex_file}")
    
    if len(hex_values) != 4096:
        print(f"Warning: Expected 4096 bytes, got {len(hex_values)}")
    
    # Create image
    img = Image.new('1', (WIDTH, HEIGHT), 0)  # 1-bit image, black background
    pixels = img.load()
    
    # VFD memory layout: each byte is 8 vertical pixels
    # Column-first ordering:
    # Byte 0 = column 0, rows 0-7
    # Byte 1 = column 0, rows 8-15
    # ...
    # Byte 15 = column 0, rows 120-127
    # Byte 16 = column 1, rows 0-7
    # etc.
    # 128 rows / 8 = 16 bytes per column
    
    BYTES_PER_COL = HEIGHT // 8  # 16
    
    for byte_idx, byte_val in enumerate(hex_values):
        # Which column (x)?
        col = byte_idx // BYTES_PER_COL
        # Which 8-row group?
        row_group = byte_idx % BYTES_PER_COL
        
        # Extract 8 bits - bit 7 (MSB) = top pixel, bit 0 (LSB) = bottom pixel
        for bit in range(8):
            row = row_group * 8 + bit
            if row < HEIGHT and col < WIDTH:
                # Bit 7 = top pixel, bit 0 = bottom pixel
                pixel_on = (byte_val >> (7 - bit)) & 1
                pixels[col, row] = pixel_on
    
    img.save(output_file)
    print(f"Saved image to {output_file}")

if __name__ == "__main__":
    hex_to_image("src/vfd_image_rom.hex", "reconstructed_image.png")
