#!/bin/bash
# Setup script for Tang Nano 20K VS Code development environment

set -e  # Exit on error

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║       Tang Nano 20K FPGA Development Environment Setup                       ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

echo "Checking system requirements..."
echo ""

# Check Python
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    print_status 0 "Python 3 found (version $PYTHON_VERSION)"
    HAS_PYTHON=1
else
    print_status 1 "Python 3 not found"
    HAS_PYTHON=0
fi

# Check pip
if command_exists pip3; then
    print_status 0 "pip3 found"
    HAS_PIP=1
else
    print_status 1 "pip3 not found"
    HAS_PIP=0
fi

# Check Gowin tools
if command_exists gw_sh; then
    print_status 0 "Gowin EDA tools (gw_sh) found"
    HAS_GOWIN=1
else
    print_status 1 "Gowin EDA tools (gw_sh) not found in PATH"
    HAS_GOWIN=0
fi

# Check openFPGALoader
if command_exists openFPGALoader; then
    print_status 0 "openFPGALoader found"
    HAS_PROGRAMMER=1
else
    print_status 1 "openFPGALoader not found"
    HAS_PROGRAMMER=0
fi

# Check VS Code
if command_exists code; then
    print_status 0 "VS Code found"
    HAS_VSCODE=1
else
    print_status 1 "VS Code (code command) not found"
    HAS_VSCODE=0
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

# Install Python dependencies
if [ $HAS_PYTHON -eq 1 ] && [ $HAS_PIP -eq 1 ]; then
    echo "Installing Python dependencies..."
    pip3 install --user Pillow
    if [ $? -eq 0 ]; then
        print_status 0 "Python dependencies installed (Pillow)"
    else
        print_status 1 "Failed to install Python dependencies"
    fi
    echo ""
else
    print_warning "Skipping Python dependencies (Python/pip not found)"
    echo ""
fi

# Offer to install openFPGALoader
if [ $HAS_PROGRAMMER -eq 0 ]; then
    echo "openFPGALoader is required for programming the FPGA."
    echo "Would you like to install it? (requires sudo) [y/N]"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if command_exists apt; then
            echo "Installing via apt..."
            sudo apt update
            sudo apt install -y openFPGALoader
            print_status $? "openFPGALoader installation"
        elif command_exists brew; then
            echo "Installing via homebrew..."
            brew install openfpgaloader
            print_status $? "openFPGALoader installation"
        else
            print_warning "Package manager not found. Please install manually:"
            echo "  https://github.com/trabucayre/openFPGALoader"
        fi
    fi
    echo ""
fi

# USB permissions setup
if [ "$(uname)" = "Linux" ]; then
    echo "Setting up USB permissions for FPGA programming..."
    if groups | grep -q plugdev; then
        print_status 0 "User already in 'plugdev' group"
    else
        echo "Adding user to 'plugdev' group (requires sudo)..."
        sudo usermod -a -G plugdev $USER
        print_status $? "Added to plugdev group"
        print_warning "You need to log out and back in for group changes to take effect"
    fi
    echo ""
fi

# Make scripts executable
echo "Making scripts executable..."
chmod +x scripts/*.py
print_status $? "Scripts made executable"
echo ""

# Install VS Code extensions
if [ $HAS_VSCODE -eq 1 ]; then
    echo "Installing VS Code extensions..."
    code --install-extension mshr-h.veriloghdl
    code --install-extension teros-technology.teroshdl
    print_status $? "VS Code extensions installed"
    echo ""
else
    print_warning "VS Code not found. Please install extensions manually:"
    echo "  - Verilog-HDL/SystemVerilog (mshr-h.veriloghdl)"
    echo "  - TerosHDL (teros-technology.teroshdl)"
    echo ""
fi

# Final summary
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Setup Summary:"
echo ""

ALL_GOOD=1

if [ $HAS_GOWIN -eq 0 ]; then
    print_warning "Gowin EDA tools not found"
    echo "  Download from: https://www.gowinsemi.com/en/support/download_eda/"
    echo "  After installing, add to PATH in ~/.bashrc:"
    echo "    export GOWIN_HOME=\"/path/to/Gowin_V1.9.x\""
    echo "    export PATH=\"\$GOWIN_HOME/IDE/bin:\$PATH\""
    echo ""
    ALL_GOOD=0
fi

if [ $HAS_PROGRAMMER -eq 0 ]; then
    print_warning "openFPGALoader not installed"
    echo "  Install: sudo apt install openFPGALoader"
    echo "  Or: https://github.com/trabucayre/openFPGALoader"
    echo ""
    ALL_GOOD=0
fi

if [ $ALL_GOOD -eq 1 ]; then
    echo -e "${GREEN}✓ All requirements met!${NC}"
    echo ""
    echo "Quick start:"
    echo "  1. make test-pattern          # Create test image"
    echo "  2. make image-rom IMAGE=test_pattern.png"
    echo "  3. Edit fpga_2_vfd.gprj to include vfd_graphics_writer.v and image_rom.v"
    echo "  4. make flash                 # Build and program"
    echo ""
    echo "Or in VS Code:"
    echo "  - Press Ctrl+Shift+B to build"
    echo "  - Open Command Palette (Ctrl+Shift+P) → 'Run Task' → 'Program FPGA'"
    echo ""
    echo "See WORKFLOW.md for complete guide!"
else
    echo "Please install missing components and run this script again."
    echo ""
    echo "See VSCODE_SETUP.md for detailed installation instructions."
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
