#!/usr/bin/env python3
"""
Stream GIF animation to VFD via UART.

Usage: python3 stream_gif.py images/skeleton.gif [--port /dev/ttyUSB1] [--fps 15]

The script converts each frame on-the-fly and streams it to the FPGA.
"""

import sys
import time
import argparse
import serial
from PIL import Image

# VFD display size
VFD_WIDTH = 256
VFD_HEIGHT = 128
BYTES_PER_FRAME = (VFD_WIDTH * VFD_HEIGHT) // 8  # 4096 bytes

def extract_frames(gif_path):
    """Extract all frames from GIF."""
    img = Image.open(gif_path)
    frames = []
    durations = []
    
    try:
        while True:
            duration = img.info.get('duration', 100)
            durations.append(duration)
            
            frame = img.convert('RGBA')
            bg = Image.new('RGBA', frame.size, (255, 255, 255, 255))
            composite = Image.alpha_composite(bg, frame)
            frames.append(composite.convert('L'))
            
            img.seek(img.tell() + 1)
    except EOFError:
        pass
    
    return frames, durations

def resize_and_dither(frame):
    """Resize frame to VFD size and apply Floyd-Steinberg dithering."""
    aspect = frame.width / frame.height
    target_aspect = VFD_WIDTH / VFD_HEIGHT
    
    if aspect > target_aspect:
        new_width = VFD_WIDTH
        new_height = int(VFD_WIDTH / aspect)
    else:
        new_height = VFD_HEIGHT
        new_width = int(VFD_HEIGHT * aspect)
    
    resized = frame.resize((new_width, new_height), Image.Resampling.LANCZOS)
    
    output = Image.new('L', (VFD_WIDTH, VFD_HEIGHT), 255)
    x_offset = (VFD_WIDTH - new_width) // 2
    y_offset = (VFD_HEIGHT - new_height) // 2
    output.paste(resized, (x_offset, y_offset))
    
    return output.convert('1')

def frame_to_bytes(frame):
    """Convert 1-bit frame to VFD byte format.
    Column-first order, bit 7 at top, bit 0 at bottom.
    """
    pixels = frame.load()
    data = []
    
    for x in range(VFD_WIDTH):
        for y_base in range(0, VFD_HEIGHT, 8):
            byte = 0
            for bit in range(8):
                y = y_base + bit
                px = pixels[x, y]
                # White pixels (255) should light up
                if px != 0:
                    byte |= (0x80 >> bit)
            data.append(byte)
    
    return bytes(data)

def main():
    parser = argparse.ArgumentParser(description='Stream GIF to VFD via UART')
    parser.add_argument('gif', help='Path to GIF file')
    parser.add_argument('--port', default='/dev/ttyUSB1', help='Serial port (default: /dev/ttyUSB1)')
    parser.add_argument('--baud', type=int, default=1000000, help='Baud rate (default: 1000000)')
    parser.add_argument('--fps', type=float, default=0, help='Override FPS (0 = use GIF timing)')
    parser.add_argument('--loop', type=int, default=0, help='Number of loops (0 = infinite)')
    args = parser.parse_args()
    
    print(f"Loading: {args.gif}")
    frames, durations = extract_frames(args.gif)
    print(f"Frames: {len(frames)}")
    
    # Pre-process all frames
    print("Processing frames...")
    frame_data = []
    for i, frame in enumerate(frames):
        dithered = resize_and_dither(frame)
        data = frame_to_bytes(dithered)
        frame_data.append(data)
        print(f"  Frame {i+1}/{len(frames)}")
    
    # Open serial port
    print(f"Opening {args.port} at {args.baud} baud...")
    ser = serial.Serial(args.port, args.baud, timeout=1)
    time.sleep(0.5)  # Wait for FPGA to be ready
    
    print("Streaming... (Ctrl+C to stop)")
    
    loop_count = 0
    try:
        while args.loop == 0 or loop_count < args.loop:
            for i, data in enumerate(frame_data):
                # Calculate frame delay
                if args.fps > 0:
                    delay = 1.0 / args.fps
                else:
                    delay = durations[i] / 1000.0
                
                # Send frame
                start = time.time()
                ser.write(data)
                ser.flush()
                send_time = time.time() - start
                
                # Wait for remaining frame time
                remaining = delay - send_time
                if remaining > 0:
                    time.sleep(remaining)
                
                # Show progress
                actual_fps = 1.0 / (time.time() - start)
                print(f"\rFrame {i+1}/{len(frames)} | {actual_fps:.1f} fps | Loop {loop_count+1}", end='')
            
            loop_count += 1
            print()
            
    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        ser.close()

if __name__ == "__main__":
    main()
