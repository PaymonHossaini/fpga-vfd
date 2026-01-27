#!/usr/bin/env python3
"""
Convert animated GIF to VFD ROM hex file for animation playback.
Resizes, dithers, and packs all frames into a single hex file.

Usage: python3 gif_to_vfd_rom.py images/skeleton.gif [frame_skip]
       frame_skip: use every Nth frame (default 1 = all frames)

Output:
  - src/vfd_animation_rom.hex (all frames concatenated)
  - src/vfd_animation_info.txt (frame count, delays)
  - images/animation_preview.gif (preview of dithered output)
"""

import sys
from PIL import Image
import os

# VFD display size
VFD_WIDTH = 256
VFD_HEIGHT = 128
BYTES_PER_FRAME = (VFD_WIDTH * VFD_HEIGHT) // 8  # 4096 bytes

def extract_frames(gif_path):
    """Extract all frames from GIF with their durations."""
    img = Image.open(gif_path)
    frames = []
    durations = []
    
    try:
        while True:
            # Get frame duration (in ms, default 100ms)
            duration = img.info.get('duration', 100)
            durations.append(duration)
            
            # Convert to RGBA to handle transparency
            frame = img.convert('RGBA')
            
            # Create white background and composite
            bg = Image.new('RGBA', frame.size, (255, 255, 255, 255))
            composite = Image.alpha_composite(bg, frame)
            frames.append(composite.convert('L'))  # Convert to grayscale
            
            img.seek(img.tell() + 1)
    except EOFError:
        pass
    
    return frames, durations

def resize_and_dither(frame):
    """Resize frame to VFD size and apply Floyd-Steinberg dithering."""
    # Calculate aspect-preserving resize
    aspect = frame.width / frame.height
    target_aspect = VFD_WIDTH / VFD_HEIGHT
    
    if aspect > target_aspect:
        # Image is wider - fit to width
        new_width = VFD_WIDTH
        new_height = int(VFD_WIDTH / aspect)
    else:
        # Image is taller - fit to height
        new_height = VFD_HEIGHT
        new_width = int(VFD_HEIGHT * aspect)
    
    # Resize with high-quality resampling
    resized = frame.resize((new_width, new_height), Image.Resampling.LANCZOS)
    
    # Create centered frame on white background
    output = Image.new('L', (VFD_WIDTH, VFD_HEIGHT), 255)
    x_offset = (VFD_WIDTH - new_width) // 2
    y_offset = (VFD_HEIGHT - new_height) // 2
    output.paste(resized, (x_offset, y_offset))
    
    # Apply Floyd-Steinberg dithering
    dithered = output.convert('1')
    
    return dithered

def frame_to_bytes(frame):
    """Convert 1-bit frame to VFD byte format.
    VFD format: Column-first order, each byte is 8 vertical pixels.
    Bit 7 at top, bit 0 at bottom.
    256 columns x 16 bytes per column (128 pixels / 8) = 4096 bytes per frame.
    """
    pixels = frame.load()
    data = []
    
    # Column-first: iterate x (columns) first, then y in groups of 8
    for x in range(VFD_WIDTH):
        for y_base in range(0, VFD_HEIGHT, 8):
            byte = 0
            for bit in range(8):
                y = y_base + bit
                px = pixels[x, y]
                # VFD: 1 = lit pixel, PIL 1-bit: 0 = black, 255 = white
                # Bit 7 at top (y_base), bit 0 at bottom (y_base + 7)
                # White pixels (255) should light up on VFD
                if px != 0:
                    byte |= (0x80 >> bit)  # bit 7 = top, bit 0 = bottom
            data.append(byte)
    
    return bytes(data)

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 gif_to_vfd_rom.py <input.gif> [frame_skip]")
        print("       frame_skip: use every Nth frame (default 1 = all frames)")
        sys.exit(1)
    
    gif_path = sys.argv[1]
    frame_skip = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    
    print(f"Processing: {gif_path}")
    print(f"Frame skip: {frame_skip} (using every {frame_skip}th frame)")
    
    # Extract frames
    all_frames, all_durations = extract_frames(gif_path)
    
    # Apply frame skipping
    frames = all_frames[::frame_skip]
    durations = [d * frame_skip for d in all_durations[::frame_skip]]  # Scale duration
    
    print(f"Using {len(frames)} of {len(all_frames)} frames")
    print(f"Frame durations (ms): {durations[:5]}..." if len(durations) > 5 else f"Frame durations (ms): {durations}")
    
    # Process all frames
    dithered_frames = []
    all_bytes = bytearray()
    
    for i, frame in enumerate(frames):
        dithered = resize_and_dither(frame)
        dithered_frames.append(dithered)
        frame_bytes = frame_to_bytes(dithered)
        all_bytes.extend(frame_bytes)
        print(f"  Frame {i+1}/{len(frames)}: {len(frame_bytes)} bytes")
    
    # Write hex file
    hex_path = "src/vfd_animation_rom.hex"
    with open(hex_path, 'w') as f:
        for byte in all_bytes:
            f.write(f"{byte:02X}\n")
    print(f"Wrote {hex_path} ({len(all_bytes)} bytes)")
    
    # Write info file
    info_path = "src/vfd_animation_info.txt"
    avg_duration = sum(durations) / len(durations)
    with open(info_path, 'w') as f:
        f.write(f"frames={len(frames)}\n")
        f.write(f"bytes_per_frame={BYTES_PER_FRAME}\n")
        f.write(f"total_bytes={len(all_bytes)}\n")
        f.write(f"avg_duration_ms={avg_duration:.1f}\n")
        f.write(f"durations_ms={','.join(str(d) for d in durations)}\n")
    print(f"Wrote {info_path}")
    
    # Create preview GIF
    preview_path = "images/animation_preview.gif"
    # Convert 1-bit frames back to RGB for preview
    preview_frames = [f.convert('RGB') for f in dithered_frames]
    preview_frames[0].save(
        preview_path,
        save_all=True,
        append_images=preview_frames[1:],
        duration=durations,
        loop=0
    )
    print(f"Wrote {preview_path}")
    
    # Print Verilog parameters
    print(f"\n=== Verilog Parameters ===")
    print(f"localparam NUM_FRAMES = {len(frames)};")
    print(f"localparam BYTES_PER_FRAME = {BYTES_PER_FRAME};")
    print(f"localparam TOTAL_BYTES = {len(all_bytes)};")
    # Calculate cycles for frame delay (27MHz clock)
    cycles_per_ms = 27000
    avg_cycles = int(avg_duration * cycles_per_ms)
    print(f"localparam FRAME_DELAY = 24'd{avg_cycles};  // {avg_duration:.0f}ms at 27MHz")

if __name__ == "__main__":
    main()
