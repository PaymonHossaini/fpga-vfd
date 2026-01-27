#!/usr/bin/env python3
"""
Stream GIF frames to VFD via UART
Protocol:
- Send 0xAA sync byte
- Send 4096 data bytes (frame)
- Wait for 0x55 acknowledgment
- Repeat
"""

import sys
import time
import argparse
from PIL import Image
import serial

FRAME_WIDTH = 256
FRAME_HEIGHT = 128
BYTES_PER_FRAME = 4096  # 256 * 128 / 8
SYNC_BYTE = 0xAA
ACK_BYTE = 0x55

def gif_to_vfd_frames(gif_path, invert=False):
    """Convert GIF to list of VFD frame data"""
    img = Image.open(gif_path)
    frames = []
    
    try:
        while True:
            # Convert frame to grayscale and resize
            frame = img.convert('L').resize((FRAME_WIDTH, FRAME_HEIGHT), Image.Resampling.LANCZOS)
            
            # Convert to 1-bit (threshold at 128)
            pixels = frame.load()
            
            # Convert to VFD format: column-first, 8 vertical pixels per byte
            # Bit 7 = top pixel, bit 0 = bottom pixel
            frame_data = bytearray(BYTES_PER_FRAME)
            
            for x in range(FRAME_WIDTH):
                for y_group in range(16):  # 128/8 = 16 bytes per column
                    byte_val = 0
                    for bit in range(8):
                        y = y_group * 8 + bit
                        pixel = pixels[x, y]
                        # Bit 7 is top (bit=0), bit 0 is bottom (bit=7)
                        bit_pos = 7 - bit
                        if invert:
                            if pixel < 128:  # Dark pixel = ON when inverted
                                byte_val |= (1 << bit_pos)
                        else:
                            if pixel >= 128:  # Light pixel = ON
                                byte_val |= (1 << bit_pos)
                    
                    # Store in column-first order
                    frame_data[x * 16 + y_group] = byte_val
            
            frames.append(bytes(frame_data))
            img.seek(img.tell() + 1)
            
    except EOFError:
        pass
    
    return frames


def stream_to_vfd(port, frames, fps=10, loop=True):
    """Stream frames to VFD over UART"""
    frame_delay = 1.0 / fps
    
    with serial.Serial(port, 1000000, timeout=2) as ser:
        print(f"Opened {port} at 1Mbaud")
        print(f"Streaming {len(frames)} frames at {fps} fps")
        
        frame_num = 0
        while True:
            for i, frame_data in enumerate(frames):
                start_time = time.time()
                
                # Send sync byte
                ser.write(bytes([SYNC_BYTE]))
                
                # Send frame data
                ser.write(frame_data)
                
                # Wait for acknowledgment
                ack = ser.read(1)
                if ack and ack[0] == ACK_BYTE:
                    elapsed = time.time() - start_time
                    remaining = frame_delay - elapsed
                    if remaining > 0:
                        time.sleep(remaining)
                    
                    frame_num += 1
                    if frame_num % 10 == 0:
                        actual_fps = 1.0 / (time.time() - start_time) if elapsed > 0 else 0
                        print(f"Frame {frame_num}: {actual_fps:.1f} fps")
                else:
                    print(f"No ACK received for frame {i}, retrying...")
                    time.sleep(0.1)
            
            if not loop:
                break
        
        print("Streaming complete")


def main():
    parser = argparse.ArgumentParser(description='Stream GIF to VFD via UART')
    parser.add_argument('gif', help='Input GIF file')
    parser.add_argument('--port', '-p', default='/dev/ttyUSB1', help='Serial port')
    parser.add_argument('--fps', '-f', type=float, default=10, help='Target FPS')
    parser.add_argument('--invert', '-i', action='store_true', help='Invert colors')
    parser.add_argument('--no-loop', action='store_true', help='Play once instead of looping')
    parser.add_argument('--test', '-t', action='store_true', help='Generate test pattern instead')
    
    args = parser.parse_args()
    
    if args.test:
        # Generate test pattern frames
        print("Generating test pattern...")
        frames = []
        for offset in range(16):
            frame_data = bytearray(BYTES_PER_FRAME)
            for x in range(FRAME_WIDTH):
                for y_group in range(16):
                    # Alternating stripes that shift
                    if ((x + offset) // 16) % 2 == 0:
                        frame_data[x * 16 + y_group] = 0xFF
                    else:
                        frame_data[x * 16 + y_group] = 0x00
            frames.append(bytes(frame_data))
    else:
        print(f"Loading {args.gif}...")
        frames = gif_to_vfd_frames(args.gif, args.invert)
    
    print(f"Loaded {len(frames)} frames")
    
    stream_to_vfd(args.port, frames, args.fps, not args.no_loop)


if __name__ == '__main__':
    main()
