#!/usr/bin/env python3
"""
BMP to VFD ROM Converter with Atkinson Dithering

Converts any image to Verilog ROM format for the GU256x128C VFD display.
- Scales image to fit 128px height, maintains aspect ratio
- Centers horizontally with zero padding
- Uses Atkinson dithering for high-quality black/white conversion

VFD Memory Layout (DMA mode):
- 256 columns x 128 rows = 256 x 16 bytes = 4096 bytes total
- Each byte = 8 vertical pixels (1 column, 8 rows)
- Address = x * 16 + y_byte where y_byte = y // 8
- Within byte: bit 0 = top pixel, bit 7 = bottom pixel

Usage:
    python3 bmp_to_vfd_rom.py input.bmp output.v [module_name]
    
Supports: BMP, PNG, JPG, GIF (requires Pillow for non-BMP)
"""

import sys
from pathlib import Path

# Try to import Pillow for better image support
try:
    from PIL import Image
    HAS_PILLOW = True
except ImportError:
    HAS_PILLOW = False
    print("Note: Install Pillow for PNG/JPG support: pip install Pillow")


def load_image_pillow(filename):
    """Load image using Pillow and convert to grayscale array"""
    img = Image.open(filename)
    
    # Convert to grayscale
    img = img.convert('L')
    
    width, height = img.size
    pixels = list(img.getdata())
    
    # Convert to 2D array
    pixel_array = []
    for y in range(height):
        row = pixels[y * width:(y + 1) * width]
        pixel_array.append(list(row))
    
    return pixel_array, width, height


def load_bmp_native(filename):
    """Load BMP file natively (no dependencies)"""
    with open(filename, 'rb') as f:
        header = f.read(14)
        if header[0:2] != b'BM':
            raise ValueError("Not a BMP file")
        
        data_offset = int.from_bytes(header[10:14], 'little')
        dib_header = f.read(40)
        width = int.from_bytes(dib_header[4:8], 'little')
        height = int.from_bytes(dib_header[8:12], 'little')
        bits_per_pixel = int.from_bytes(dib_header[14:16], 'little')
        compression = int.from_bytes(dib_header[16:20], 'little')
        
        if compression != 0:
            raise ValueError("Compressed BMPs not supported")
        
        f.seek(data_offset)
        
        if bits_per_pixel == 1:
            row_size = ((width + 31) // 32) * 4
        elif bits_per_pixel == 8:
            row_size = ((width + 3) // 4) * 4
        elif bits_per_pixel == 24:
            row_size = ((width * 3 + 3) // 4) * 4
        elif bits_per_pixel == 32:
            row_size = width * 4
        else:
            raise ValueError(f"Unsupported bits per pixel: {bits_per_pixel}")
        
        pixels = []
        for y in range(height):
            row_data = f.read(row_size)
            row_pixels = []
            
            if bits_per_pixel == 1:
                for x in range(width):
                    byte_idx = x // 8
                    bit_idx = 7 - (x % 8)
                    pixel = (row_data[byte_idx] >> bit_idx) & 1
                    row_pixels.append(255 if pixel else 0)
            elif bits_per_pixel == 8:
                for x in range(width):
                    row_pixels.append(row_data[x])
            elif bits_per_pixel == 24:
                for x in range(width):
                    b = row_data[x * 3]
                    g = row_data[x * 3 + 1]
                    r = row_data[x * 3 + 2]
                    gray = (r * 299 + g * 587 + b * 114) // 1000
                    row_pixels.append(gray)
            elif bits_per_pixel == 32:
                for x in range(width):
                    b = row_data[x * 4]
                    g = row_data[x * 4 + 1]
                    r = row_data[x * 4 + 2]
                    gray = (r * 299 + g * 587 + b * 114) // 1000
                    row_pixels.append(gray)
            
            pixels.append(row_pixels)
        
        pixels = pixels[::-1]  # BMP is bottom-up
        return pixels, width, height


def load_image(filename):
    """Load image file, returns grayscale pixel array (0-255)"""
    if HAS_PILLOW:
        return load_image_pillow(filename)
    elif filename.lower().endswith('.bmp'):
        return load_bmp_native(filename)
    else:
        raise ValueError("Non-BMP files require Pillow: pip install Pillow")


def scale_image(pixels, src_width, src_height, target_height=128, target_width=256):
    """Scale image to target height, maintain aspect ratio, center horizontally"""
    
    # Calculate new dimensions maintaining aspect ratio
    scale = target_height / src_height
    new_width = int(src_width * scale)
    new_height = target_height
    
    # Cap width at target
    if new_width > target_width:
        scale = target_width / src_width
        new_width = target_width
        new_height = int(src_height * scale)
    
    print(f"Scaling: {src_width}x{src_height} -> {new_width}x{new_height}")
    
    # Bilinear interpolation scaling
    scaled = []
    for y in range(new_height):
        row = []
        src_y = y * src_height / new_height
        y0 = int(src_y)
        y1 = min(y0 + 1, src_height - 1)
        fy = src_y - y0
        
        for x in range(new_width):
            src_x = x * src_width / new_width
            x0 = int(src_x)
            x1 = min(x0 + 1, src_width - 1)
            fx = src_x - x0
            
            # Bilinear interpolation
            p00 = pixels[y0][x0]
            p10 = pixels[y0][x1]
            p01 = pixels[y1][x0]
            p11 = pixels[y1][x1]
            
            val = (p00 * (1-fx) * (1-fy) + 
                   p10 * fx * (1-fy) + 
                   p01 * (1-fx) * fy + 
                   p11 * fx * fy)
            row.append(int(val))
        scaled.append(row)
    
    # Left-align (padding on right) to test if glitch is position or data-stream related
    x_offset = 0  # Was: (target_width - new_width) // 2
    y_offset = (target_height - new_height) // 2
    
    result = [[255] * target_width for _ in range(target_height)]
    for y in range(new_height):
        for x in range(new_width):
            result[y + y_offset][x + x_offset] = scaled[y][x]
    
    return result, target_width, target_height


def atkinson_dither(pixels, width, height, threshold=128):
    """
    Apply Atkinson dithering algorithm.
    
    Atkinson distributes 6/8 (75%) of the error to neighboring pixels:
    
        *   1/8  1/8
    1/8 1/8 1/8
        1/8
    
    This creates a lighter, more artistic look than Floyd-Steinberg.
    """
    # Work with floats to accumulate error
    img = [[float(pixels[y][x]) for x in range(width)] for y in range(height)]
    output = [[0] * width for _ in range(height)]
    
    for y in range(height):
        for x in range(width):
            old_pixel = img[y][x]
            new_pixel = 255 if old_pixel >= threshold else 0
            output[y][x] = 1 if new_pixel == 255 else 0  # 1=white/on, 0=black/off
            
            error = (old_pixel - new_pixel) / 8.0  # 1/8 of error
            
            # Distribute error to neighbors (Atkinson pattern)
            # Right
            if x + 1 < width:
                img[y][x + 1] += error
            # Right + 1
            if x + 2 < width:
                img[y][x + 2] += error
            # Below left
            if y + 1 < height and x - 1 >= 0:
                img[y + 1][x - 1] += error
            # Below
            if y + 1 < height:
                img[y + 1][x] += error
            # Below right
            if y + 1 < height and x + 1 < width:
                img[y + 1][x + 1] += error
            # Two below
            if y + 2 < height:
                img[y + 2][x] += error
    
    return output


def convert_to_vfd_bytes(pixels, width, height):
    """Convert 1-bit pixel array to VFD byte format.
    
    VFD expects MSB first (bit 7 = top pixel), so we build bytes that way.
    """
    
    vfd_data = []
    
    # VFD memory layout: address = x * 16 + y_byte
    for x in range(width):
        for y_byte in range(height // 8):
            byte_val = 0
            for bit in range(8):
                y = y_byte * 8 + bit
                if pixels[y][x]:  # Pixel is on (white)
                    # MSB first: bit 7 = top pixel (y_byte*8 + 0)
                    # So bit position is (7 - bit)
                    byte_val |= (1 << (7 - bit))
            
            vfd_data.append(byte_val)
    
    return vfd_data


def generate_verilog_rom(vfd_data, module_name, output_file):
    """Generate Verilog ROM module using block RAM with inline initialization"""
    
    # Count non-zero entries
    non_zero = [(i, b) for i, b in enumerate(vfd_data) if b != 0]
    
    with open(output_file, 'w') as f:
        f.write(f"// VFD Image ROM - Auto-generated (Block RAM with inline init)\n")
        f.write(f"// Total bytes: {len(vfd_data)}\n")
        f.write(f"// Non-zero bytes: {len(non_zero)}\n\n")
        f.write(f"module {module_name} (\n")
        f.write(f"    input wire clk,\n")
        f.write(f"    input wire [12:0] addr,\n")
        f.write(f"    output reg [7:0] data\n")
        f.write(f");\n\n")
        f.write(f"    // Block RAM storage\n")
        f.write(f"    reg [7:0] mem [0:4095];\n\n")
        f.write(f"    // Initialize memory inline\n")
        f.write(f"    initial begin\n")
        for i, byte_val in enumerate(vfd_data):
            f.write(f"        mem[{i}] = 8'h{byte_val:02X};\n")
        f.write(f"    end\n\n")
        f.write(f"    // Synchronous read\n")
        f.write(f"    always @(posedge clk) begin\n")
        f.write(f"        data <= mem[addr];\n")
        f.write(f"    end\n")
        f.write(f"endmodule\n")
    
    print(f"Generated: {output_file}")


def save_preview(pixels, width, height, filename):
    """Save a preview image (requires Pillow)"""
    if not HAS_PILLOW:
        return
    
    img = Image.new('1', (width, height))
    for y in range(height):
        for x in range(width):
            # pixels: 1=on/white, 0=off/black
            # PIL: 0=black, 1=white
            img.putpixel((x, y), pixels[y][x])
    
    preview_file = filename.replace('.v', '_preview.png')
    img.save(preview_file)
    print(f"Preview saved: {preview_file}")


def save_vfd_preview(vfd_data, width, height, filename):
    """
    Save a preview reconstructed from VFD bytes.
    This shows exactly what the VFD will display.
    
    VFD layout: address = x * 16 + y_byte
    Each byte is 8 vertical pixels, bit 7 = top pixel, bit 0 = bottom pixel
    """
    if not HAS_PILLOW:
        print("Install Pillow for preview: pip install Pillow")
        return
    
    # Reconstruct image from VFD bytes
    img = Image.new('1', (width, height))
    
    for x in range(width):
        for y_byte in range(height // 8):
            addr = x * 16 + y_byte
            if addr < len(vfd_data):
                byte_val = vfd_data[addr]
                for bit in range(8):
                    y = y_byte * 8 + bit
                    # bit 7 = top pixel, bit 0 = bottom pixel, 1 = pixel on
                    pixel_on = (byte_val >> (7 - bit)) & 1
                    # PIL: 0 = black, 1 = white
                    img.putpixel((x, y), 0 if pixel_on else 1)
    
    preview_file = filename.replace('.v', '_vfd_preview.bmp')
    img.save(preview_file)
    print(f"VFD preview saved: {preview_file}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 bmp_to_vfd_rom.py input.bmp output.v [module_name]")
        print("\nConverts image to Verilog ROM for VFD display")
        print("- Scales to 128px height, maintains aspect ratio")
        print("- Centers horizontally on 256px width")
        print("- Uses Atkinson dithering for B&W conversion")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    module_name = sys.argv[3] if len(sys.argv) > 3 else "vfd_image_rom"
    
    print(f"Loading: {input_file}")
    pixels, width, height = load_image(input_file)
    print(f"Original size: {width}x{height}")
    
    print(f"Scaling to fit 256x128...")
    pixels, width, height = scale_image(pixels, width, height, 128, 256)
    
    print(f"Applying Atkinson dithering...")
    pixels = atkinson_dither(pixels, width, height)
    
    print(f"Converting to VFD format...")
    vfd_data = convert_to_vfd_bytes(pixels, width, height)
    
    print(f"Generating Verilog ROM...")
    generate_verilog_rom(vfd_data, module_name, output_file)
    
    # Save preview if Pillow available
    save_preview(pixels, width, height, output_file)
    
    # Save VFD byte layout preview (what display will actually show)
    save_vfd_preview(vfd_data, width, height, output_file)
    
    print(f"\nDone! {len(vfd_data)} bytes generated")
    print(f"Non-zero bytes: {sum(1 for b in vfd_data if b != 0)}")

