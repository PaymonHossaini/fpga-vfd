#!/usr/bin/env python3
"""
Generate Verilog dot coordinates for a 256x128 display test
Creates a grid of dots covering the entire display
"""

# Generate grid of dots: 16 columns x 8 rows = 128 dots
# Display size: 256x128
# Margin: 10 pixels
# Spacing: roughly 14 pixels apart horizontally, 14 pixels apart vertically

dots = []

# Create grid pattern
for row in range(10):  # 10 rows
    for col in range(16):  # 16 columns
        x = 10 + col * 15  # 10 to 235 in steps of 15
        y = 10 + row * 12  # 10 to 130 in steps of 12
        
        # Skip if out of bounds
        if x >= 256 or y >= 128:
            continue
            
        dots.append((x, y))

print(f"// Generated {len(dots)} dot positions")
print("// Grid pattern across 256x128 display")
print()

# Output Verilog case statements
for i, (x, y) in enumerate(dots[:40]):  # First 40 dots for testing
    # Each dot is 9 bytes: 1F 28 64 10 01 xL xH yL yH
    base = i * 9 + 3  # Start after init and clear (bytes 0-2)
    
    # Print header comment every 4 dots
    if i % 4 == 0:
        print(f"// Dots {i}-{min(i+3, len(dots)-1)}")
    
    print(f"                // Dot {i} at ({x}, {y})")
    print(f"                10'd{base}:   begin current_byte = 8'h1F; post_delay = DELAY_SHORT; end")
    print(f"                10'd{base+1}: begin current_byte = 8'h28; post_delay = DELAY_SHORT; end")
    print(f"                10'd{base+2}: begin current_byte = 8'h64; post_delay = DELAY_SHORT; end")
    print(f"                10'd{base+3}: begin current_byte = 8'h10; post_delay = DELAY_SHORT; end")
    print(f"                10'd{base+4}: begin current_byte = 8'h01; post_delay = DELAY_SHORT; end")
    print(f"                10'd{base+5}: begin current_byte = 8'h{x:02X}; post_delay = DELAY_SHORT; end")
    print(f"                10'd{base+6}: begin current_byte = 8'h00; post_delay = DELAY_SHORT; end")
    print(f"                10'd{base+7}: begin current_byte = 8'h{y:02X}; post_delay = DELAY_SHORT; end")
    print(f"                10'd{base+8}: begin current_byte = 8'h00; post_delay = DELAY_LONG; end")
    print()

print(f"Total bytes needed: {3 + len(dots[:40]) * 9} (3 init + {len(dots[:40])} dots × 9)")
