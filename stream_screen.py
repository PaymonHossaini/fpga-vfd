#!/usr/bin/env python3
"""
Stream desktop screen capture to VFD display via UART.
Captures, dithers, and streams in real-time.
"""

import serial
import argparse
import time
from PIL import Image, ImageGrab
import sys

try:
    import mss
    HAS_MSS = True
except ImportError:
    HAS_MSS = False
    print("Note: Install 'mss' for faster screen capture: pip install mss")

FRAME_SIZE = 4096  # 256 columns * 16 bytes per column
SYNC_PATTERN = bytes([0xAA, 0x55, 0xAA, 0x55])
VFD_WIDTH = 256
VFD_HEIGHT = 128

def resize_and_dither(img):
    """Resize image to VFD size and apply Floyd-Steinberg dithering."""
    # Convert to grayscale
    frame = img.convert('L')
    
    # Calculate aspect-preserving resize
    aspect = frame.width / frame.height
    target_aspect = VFD_WIDTH / VFD_HEIGHT
    
    if aspect > target_aspect:
        new_width = VFD_WIDTH
        new_height = int(VFD_WIDTH / aspect)
    else:
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

def capture_screen_mss(sct, monitor):
    """Capture screen using mss (faster)."""
    screenshot = sct.grab(monitor)
    return Image.frombytes('RGB', screenshot.size, screenshot.bgra, 'raw', 'BGRX')

def capture_screen_pil():
    """Capture screen using PIL (slower but no extra deps)."""
    return ImageGrab.grab()

def capture_screen_gnome():
    """Capture screen using gnome-screenshot (works on Wayland)."""
    import subprocess
    import tempfile
    import os
    
    with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as f:
        tmp_path = f.name
    
    try:
        subprocess.run(['gnome-screenshot', '-f', tmp_path], 
                      check=True, capture_output=True)
        img = Image.open(tmp_path)
        img.load()  # Force load before deleting file
        return img.copy()
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)

def capture_screen_grim():
    """Capture screen using grim (Wayland)."""
    import subprocess
    import io
    
    result = subprocess.run(['grim', '-'], capture_output=True, check=True)
    return Image.open(io.BytesIO(result.stdout))

def stream_screen(port, baud=1000000, region=None, invert=False):
    """Stream screen captures to FPGA via UART."""
    global HAS_MSS
    
    try:
        ser = serial.Serial(port, baud, timeout=1)
        ser.reset_input_buffer()
        ser.reset_output_buffer()
    except Exception as e:
        print(f"Error opening serial port {port}: {e}")
        sys.exit(1)
    
    print(f"Streaming screen to {port} at {baud} baud")
    print("Press Ctrl+C to stop")
    
    frame_count = 0
    start_time = time.time()
    
    if HAS_MSS:
        try:
            sct = mss.mss()
            if region:
                monitor = {"left": region[0], "top": region[1], 
                          "width": region[2], "height": region[3]}
            else:
                monitor = sct.monitors[1]  # Primary monitor
            # Test capture
            test = sct.grab(monitor)
            capture_func = lambda: capture_screen_mss(sct, monitor)
            print("Using mss for screen capture")
        except Exception as e:
            print(f"mss failed ({e}), trying alternatives...")
            HAS_MSS = False
    
    if not HAS_MSS:
        # Try grim (Wayland)
        import subprocess
        try:
            subprocess.run(['grim', '--help'], capture_output=True, check=True)
            capture_func = capture_screen_grim
            print("Using grim for screen capture (Wayland)")
        except (subprocess.CalledProcessError, FileNotFoundError):
            # Try gnome-screenshot
            try:
                subprocess.run(['gnome-screenshot', '--help'], capture_output=True, check=True)
                capture_func = capture_screen_gnome
                print("Using gnome-screenshot for screen capture")
            except (subprocess.CalledProcessError, FileNotFoundError):
                # Fall back to PIL
                capture_func = capture_screen_pil
                print("Using PIL for screen capture")
    
    try:
        while True:
            frame_start = time.time()
            
            # Capture screen
            img = capture_func()
            
            # Dither and convert
            dithered = resize_and_dither(img)
            
            # Optionally invert
            if invert:
                dithered = Image.eval(dithered, lambda x: 255 - x)
            
            frame_bytes = frame_to_bytes(dithered)
            
            # Clear buffer and send
            ser.reset_input_buffer()
            ser.write(SYNC_PATTERN)
            ser.flush()
            time.sleep(0.008)
            
            ser.write(frame_bytes)
            ser.flush()
            
            # Calculate FPS
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
        ser.close()

def main():
    parser = argparse.ArgumentParser(description='Stream screen to VFD display')
    parser.add_argument('--port', '-p', default='/dev/ttyUSB1', help='Serial port')
    parser.add_argument('--baud', '-b', type=int, default=1000000, help='Baud rate')
    parser.add_argument('--region', '-r', type=int, nargs=4, metavar=('X', 'Y', 'W', 'H'),
                        help='Screen region to capture (x, y, width, height)')
    parser.add_argument('--invert', '-i', action='store_true', help='Invert colors')
    
    args = parser.parse_args()
    
    stream_screen(args.port, args.baud, args.region, args.invert)

if __name__ == '__main__':
    main()
