#!/usr/bin/env python3
"""
Convert an image to Verilog ROM for the GU256x128C VFD Display
Usage: python3 image_to_verilog.py input_image.png output_rom.v
"""

import sys
from PIL import Image

def image_to_verilog_rom(image_path, output_path, module_name="image_rom"):
    """
    Convert an image file to a Verilog ROM module.
    
    Args:
        image_path: Path to input image (will be converted to 256x128 monochrome)
        output_path: Path to output Verilog file
        module_name: Name of the Verilog module
    """
    # Load and convert image
    print(f"Loading image: {image_path}")
    img = Image.open(image_path)
    
    # Convert to grayscale then binary (1-bit)
    img = img.convert('L')  # Grayscale
    img = img.resize((256, 128), Image.Resampling.LANCZOS)
    
    # Apply threshold to convert to 1-bit (black/white)
    threshold = 128
    img = img.point(lambda p: 255 if p > threshold else 0, '1')
    
    print(f"Image size: {img.size}")
    print(f"Image mode: {img.mode}")
    
    # Get pixel data
    pixels = list(img.getdata())
    total_pixels = len(pixels)
    
    # Pack pixels into bytes (8 pixels per byte)
    bytes_data = []
    for i in range(0, total_pixels, 8):
        byte_val = 0
        for j in range(8):
            if i + j < total_pixels:
                # 1 = white pixel, 0 = black pixel
                if pixels[i + j]:
                    byte_val |= (1 << j)
        bytes_data.append(byte_val)
    
    print(f"Generated {len(bytes_data)} bytes of data")
    
    # Write Verilog file
    with open(output_path, 'w') as f:
        f.write('//\n')
        f.write(f'// Image ROM for VFD Display (GU256x128C)\n')
        f.write(f'// Generated from: {image_path}\n')
        f.write(f'// Resolution: 256x128 pixels\n')
        f.write(f'// Data format: 8 pixels per byte, LSB first\n')
        f.write('//\n\n')
        
        f.write(f'module {module_name} (\n')
        f.write('    input  wire [14:0] addr,  // Address: 0 to 4095 (256*128/8 bytes)\n')
        f.write('    output reg  [7:0]  data   // 8-bit data output\n')
        f.write(');\n\n')
        
        f.write('    always @(*) begin\n')
        f.write('        case (addr)\n')
        
        # Write ROM data
        for i, byte_val in enumerate(bytes_data):
            f.write(f"            15'd{i}: data = 8'h{byte_val:02X};\n")
        
        f.write('            default: data = 8\'h00;\n')
        f.write('        endcase\n')
        f.write('    end\n\n')
        f.write('endmodule\n')
    
    print(f"Verilog ROM written to: {output_path}")
    print(f"\nModule usage:")
    print(f"    {module_name} rom_inst (")
    print(f"        .addr(address),  // 15-bit address")
    print(f"        .data(rom_data)  // 8-bit data out")
    print(f"    );")

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 image_to_verilog.py <input_image> <output.v> [module_name]")
        print("\nExample:")
        print("  python3 image_to_verilog.py logo.png src/image_rom.v")
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    module_name = sys.argv[3] if len(sys.argv) > 3 else "image_rom"
    
    try:
        image_to_verilog_rom(input_path, output_path, module_name)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
