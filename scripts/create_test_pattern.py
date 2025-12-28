#!/usr/bin/env python3
"""
Create a simple test pattern for the VFD display
Generates a checkerboard or test grid
"""

import sys
from PIL import Image, ImageDraw, ImageFont

def create_test_pattern(width=256, height=128):
    """Create a test pattern image"""
    img = Image.new('L', (width, height), color=0)  # Black background
    draw = ImageDraw.Draw(img)
    
    # Draw border
    draw.rectangle([0, 0, width-1, height-1], outline=255, width=2)
    
    # Draw grid
    for x in range(0, width, 32):
        draw.line([(x, 0), (x, height)], fill=128, width=1)
    for y in range(0, height, 32):
        draw.line([(0, y), (width, y)], fill=128, width=1)
    
    # Draw diagonal
    draw.line([(0, 0), (width, height)], fill=255, width=2)
    draw.line([(width, 0), (0, height)], fill=255, width=2)
    
    # Draw text in center
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 24)
    except:
        font = ImageFont.load_default()
    
    text = "FPGA VFD"
    # Get text bounding box
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (width - text_width) // 2
    y = (height - text_height) // 2
    
    draw.text((x, y), text, fill=255, font=font)
    
    return img

def create_checkerboard(width=256, height=128, square_size=16):
    """Create a checkerboard pattern"""
    img = Image.new('1', (width, height))
    draw = ImageDraw.Draw(img)
    
    for y in range(0, height, square_size):
        for x in range(0, width, square_size):
            if ((x // square_size) + (y // square_size)) % 2 == 0:
                draw.rectangle([x, y, x+square_size-1, y+square_size-1], fill=1)
    
    return img

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 create_test_pattern.py <output.png> [pattern_type]")
        print("\nPattern types:")
        print("  grid       - Test grid with border and diagonals (default)")
        print("  checker    - Checkerboard pattern")
        sys.exit(1)
    
    output_path = sys.argv[1]
    pattern_type = sys.argv[2] if len(sys.argv) > 2 else "grid"
    
    if pattern_type == "checker":
        img = create_checkerboard()
    else:
        img = create_test_pattern()
    
    img.save(output_path)
    print(f"Test pattern saved to: {output_path}")
    print(f"Size: {img.size}")
    print(f"Mode: {img.mode}")

if __name__ == "__main__":
    main()
