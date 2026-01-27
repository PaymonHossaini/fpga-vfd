#!/usr/bin/env python3
"""
Stream video file or webcam to VFD display via UART.
Works in WSL since it doesn't need screen capture.
"""

import serial
import argparse
import time
from PIL import Image
import sys

try:
    import cv2
    HAS_CV2 = True
except ImportError:
    HAS_CV2 = False
    print("Install opencv: pip install opencv-python")

FRAME_SIZE = 4096
SYNC_PATTERN = bytes([0xAA, 0x55, 0xAA, 0x55])
VFD_WIDTH = 256
VFD_HEIGHT = 128

def resize_and_dither(img):
    """Resize image to VFD size and apply Floyd-Steinberg dithering."""
    frame = img.convert('L')
    
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
    
    dithered = output.convert('1')
    return dithered

def frame_to_bytes(frame):
    """Convert 1-bit frame to VFD byte format."""
    pixels = frame.load()
    data = bytearray(FRAME_SIZE)
    
    for x in range(VFD_WIDTH):
        for y_base in range(0, VFD_HEIGHT, 8):
            byte = 0
            for bit in range(8):
                y = y_base + bit
                px = pixels[x, y]
                if px != 0:
                    byte |= (0x80 >> bit)
            data[x * 16 + y_base // 8] = byte
    
    return bytes(data)

def stream_video(source, port, baud=1000000, loop=True, invert=False):
    """Stream video to FPGA via UART."""
    
    if not HAS_CV2:
        print("OpenCV required. Install with: pip install opencv-python")
        sys.exit(1)
    
    # Open video source (file path or camera index)
    if source.isdigit():
        cap = cv2.VideoCapture(int(source))
        print(f"Opening camera {source}")
    else:
        cap = cv2.VideoCapture(source)
        print(f"Opening video: {source}")
    
    if not cap.isOpened():
        print(f"Error: Could not open video source: {source}")
        sys.exit(1)
    
    try:
        ser = serial.Serial(port, baud, timeout=1)
        ser.reset_input_buffer()
        ser.reset_output_buffer()
    except Exception as e:
        print(f"Error opening serial port {port}: {e}")
        sys.exit(1)
    
    print(f"Streaming to {port} at {baud} baud")
    print("Press Ctrl+C to stop")
    
    frame_count = 0
    start_time = time.time()
    
    try:
        while True:
            frame_start = time.time()
            
            ret, frame = cap.read()
            if not ret:
                if loop:
                    cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
                    continue
                else:
                    break
            
            # Convert BGR to RGB then to PIL Image
            img = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            
            # Dither and convert
            dithered = resize_and_dither(img)
            
            if invert:
                dithered = Image.eval(dithered, lambda x: 255 - x)
            
            frame_bytes = frame_to_bytes(dithered)
            
            # Send to FPGA
            ser.reset_input_buffer()
            ser.write(SYNC_PATTERN)
            ser.flush()
            time.sleep(0.008)
            
            ser.write(frame_bytes)
            ser.flush()
            
            frame_count += 1
            elapsed = time.time() - start_time
            fps = frame_count / elapsed if elapsed > 0 else 0
            
            # Wait for transmission
            tx_time = (4100 * 10) / baud
            frame_elapsed = time.time() - frame_start
            if frame_elapsed < tx_time:
                time.sleep(tx_time - frame_elapsed + 0.005)
            
            print(f"\rFPS: {fps:.1f}  Frames: {frame_count}", end='', flush=True)
            
    except KeyboardInterrupt:
        print(f"\nStopped. Average FPS: {frame_count / (time.time() - start_time):.1f}")
    finally:
        cap.release()
        ser.close()

def main():
    parser = argparse.ArgumentParser(description='Stream video to VFD display')
    parser.add_argument('source', help='Video file path or camera index (0, 1, etc)')
    parser.add_argument('--port', '-p', default='/dev/ttyUSB1', help='Serial port')
    parser.add_argument('--baud', '-b', type=int, default=1000000, help='Baud rate')
    parser.add_argument('--no-loop', action='store_true', help='Play once, no loop')
    parser.add_argument('--invert', '-i', action='store_true', help='Invert colors')
    
    args = parser.parse_args()
    
    stream_video(args.source, args.port, args.baud, not args.no_loop, args.invert)

if __name__ == '__main__':
    main()
