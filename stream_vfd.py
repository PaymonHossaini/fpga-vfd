#!/usr/bin/env python3
"""
Stream GIF animation to VFD display via UART.
FPGA expects: sync byte (0xAA), then 4096 bytes per frame.
FPGA sends back 0x55 when ready for next frame.
"""

import serial
import argparse
import time
from PIL import Image
import sys

FRAME_SIZE = 4096  # 256 columns * 16 bytes per column
SYNC_PATTERN = bytes([0xAA, 0x55, 0xAA, 0x55])  # 4-byte sync pattern
VFD_WIDTH = 256
VFD_HEIGHT = 128

def resize_and_dither(frame):
    """Resize frame to VFD size and apply Floyd-Steinberg dithering."""
    # Handle transparency
    if frame.mode == 'RGBA':
        bg = Image.new('RGBA', frame.size, (255, 255, 255, 255))
        frame = Image.alpha_composite(bg, frame)
    
    frame = frame.convert('L')
    
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
    """
    pixels = frame.load()
    data = bytearray(FRAME_SIZE)
    
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
                    byte |= (0x80 >> bit)
            data[x * 16 + y_base // 8] = byte
    
    return bytes(data)

def gif_to_vfd_frames(gif_path):
    """Convert GIF to list of VFD frame bytes."""
    frames = []
    
    try:
        img = Image.open(gif_path)
    except Exception as e:
        print(f"Error opening {gif_path}: {e}")
        sys.exit(1)
    
    print(f"Source image: {img.width}x{img.height}")
    
    frame_num = 0
    try:
        while True:
            # Convert frame to RGBA to handle transparency
            frame = img.convert('RGBA')
            
            # Resize and dither
            dithered = resize_and_dither(frame)
            
            # Convert to VFD bytes
            frame_bytes = frame_to_bytes(dithered)
            frames.append(frame_bytes)
            
            frame_num += 1
            img.seek(img.tell() + 1)
            
    except EOFError:
        pass  # End of GIF frames
    
    print(f"Loaded {len(frames)} frames from {gif_path}")
    return frames

def stream_frames(frames, port, baud=1000000, fps=10, loop=True):
    """Stream frames to FPGA via UART."""
    
    try:
        ser = serial.Serial(port, baud, timeout=1)
        ser.reset_input_buffer()
        ser.reset_output_buffer()
    except Exception as e:
        print(f"Error opening serial port {port}: {e}")
        sys.exit(1)
    
    print(f"Streaming to {port} at {baud} baud, {fps} fps")
    print("Press Ctrl+C to stop")
    
    frame_delay = 1.0 / fps
    frame_idx = 0
    
    try:
        while True:
            start_time = time.time()
            frame = frames[frame_idx]
            
            # Clear any stale data
            ser.reset_input_buffer()
            
            # Send 4-byte sync pattern
            ser.write(SYNC_PATTERN)
            ser.flush()
            
            # Wait for FPGA to send VFD header (minimal delay)
            time.sleep(0.008)
            
            # Send frame data
            ser.write(frame)
            ser.flush()
            
            # Minimal delay - just enough for transmission + VFD write
            # At 1Mbaud: 4100 bytes * 10 bits = 41ms transmission
            # VFD write is very fast in DMA mode
            tx_time = (4100 * 10) / baud
            
            # Wait just for transmission to complete
            elapsed = time.time() - start_time
            remaining = max(0.01, tx_time - elapsed + 0.005)
            time.sleep(remaining)
            
            # Calculate time spent sending, sleep for remainder of frame period
            elapsed = time.time() - start_time
            sleep_time = frame_delay - elapsed
            if sleep_time > 0:
                time.sleep(sleep_time)
            
            frame_idx += 1
            if frame_idx >= len(frames):
                if loop:
                    frame_idx = 0
                else:
                    break
            
            # Show progress
            print(f"\rFrame {frame_idx}/{len(frames)}", end='', flush=True)
            
    except KeyboardInterrupt:
        print("\nStopped")
    finally:
        ser.close()

def main():
    parser = argparse.ArgumentParser(description='Stream GIF to VFD display')
    parser.add_argument('gif', help='GIF file to stream')
    parser.add_argument('--port', '-p', default='/dev/ttyUSB1', help='Serial port')
    parser.add_argument('--baud', '-b', type=int, default=1000000, help='Baud rate')
    parser.add_argument('--fps', '-f', type=int, default=10, help='Frames per second')
    parser.add_argument('--skip', '-s', type=int, default=1, help='Use every Nth frame (1=all, 2=half, etc)')
    parser.add_argument('--no-loop', action='store_true', help='Play once, no loop')
    
    args = parser.parse_args()
    
    frames = gif_to_vfd_frames(args.gif)
    
    if not frames:
        print("No frames loaded!")
        sys.exit(1)
    
    # Apply frame skipping
    if args.skip > 1:
        frames = frames[::args.skip]
        print(f"After skipping: {len(frames)} frames (using every {args.skip}th frame)")
    
    stream_frames(frames, args.port, args.baud, args.fps, not args.no_loop)

if __name__ == '__main__':
    main()
