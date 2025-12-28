# Makefile for Tang Nano 20K FPGA Project
# Requires: Gowin EDA toolchain and openFPGALoader

# Project settings
PROJECT = fpga_2_vfd
GPRJ_FILE = $(PROJECT).gprj
BITSTREAM = impl/pnr/$(PROJECT).fs
BOARD = tangnano20k

# Gowin tools (adjust paths if needed)
GW_SH = gw_sh
PROGRAMMER = openFPGALoader

# Python scripts
PYTHON = python3
IMAGE_SCRIPT = scripts/image_to_verilog.py
PATTERN_SCRIPT = scripts/create_test_pattern.py

# Default target
.PHONY: all
all: build

# Build (synthesize and place & route)
.PHONY: build
build:
	@echo "Building project..."
	$(GW_SH) $(GPRJ_FILE)
	@echo "Build complete! Bitstream: $(BITSTREAM)"

# Program FPGA
.PHONY: program
program: $(BITSTREAM)
	@echo "Programming FPGA..."
	$(PROGRAMMER) -b $(BOARD) $(BITSTREAM)

# Build and program in one step
.PHONY: flash
flash: build program

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -rf impl/
	@echo "Clean complete!"

# Create test pattern image
.PHONY: test-pattern
test-pattern:
	@echo "Creating test pattern..."
	$(PYTHON) $(PATTERN_SCRIPT) test_pattern.png grid
	@echo "Test pattern saved to test_pattern.png"

# Create checkerboard pattern
.PHONY: test-checker
test-checker:
	@echo "Creating checkerboard pattern..."
	$(PYTHON) $(PATTERN_SCRIPT) test_checker.png checker
	@echo "Checkerboard saved to test_checker.png"

# Convert image to Verilog ROM
# Usage: make image-rom IMAGE=myimage.png
.PHONY: image-rom
image-rom:
ifndef IMAGE
	@echo "Error: Please specify IMAGE=<filename>"
	@echo "Example: make image-rom IMAGE=logo.png"
	@exit 1
endif
	@echo "Converting $(IMAGE) to Verilog ROM..."
	$(PYTHON) $(IMAGE_SCRIPT) $(IMAGE) src/image_rom.v
	@echo "ROM created: src/image_rom.v"

# View synthesis report
.PHONY: report
report:
	@if [ -f impl/pnr/$(PROJECT).rpt.txt ]; then \
		less impl/pnr/$(PROJECT).rpt.txt; \
	else \
		echo "No report found. Run 'make build' first."; \
	fi

# View resource utilization
.PHONY: resources
resources:
	@if [ -f impl/pnr/$(PROJECT).rpt.txt ]; then \
		grep -A 30 "Device Utilization" impl/pnr/$(PROJECT).rpt.txt || echo "Resource info not found"; \
	else \
		echo "No report found. Run 'make build' first."; \
	fi

# View timing report
.PHONY: timing
timing:
	@if [ -f impl/pnr/$(PROJECT).rpt.txt ]; then \
		grep -A 20 "Timing" impl/pnr/$(PROJECT).rpt.txt || echo "Timing info not found"; \
	else \
		echo "No report found. Run 'make build' first."; \
	fi

# Install Python dependencies
.PHONY: install-deps
install-deps:
	@echo "Installing Python dependencies..."
	pip3 install Pillow
	@echo "Dependencies installed!"

# Check if tools are installed
.PHONY: check-tools
check-tools:
	@echo "Checking for required tools..."
	@which $(GW_SH) > /dev/null || echo "WARNING: gw_sh not found in PATH"
	@which $(PROGRAMMER) > /dev/null || echo "WARNING: openFPGALoader not found"
	@which $(PYTHON) > /dev/null || echo "WARNING: python3 not found"
	@echo "Tool check complete."

# Help
.PHONY: help
help:
	@echo "Tang Nano 20K FPGA Project - Make targets:"
	@echo ""
	@echo "Building:"
	@echo "  make build          - Synthesize and place & route"
	@echo "  make program        - Program the FPGA"
	@echo "  make flash          - Build and program in one step"
	@echo "  make clean          - Remove build artifacts"
	@echo ""
	@echo "Images:"
	@echo "  make test-pattern   - Create test grid pattern"
	@echo "  make test-checker   - Create checkerboard pattern"
	@echo "  make image-rom IMAGE=<file> - Convert image to Verilog ROM"
	@echo ""
	@echo "Reports:"
	@echo "  make report         - View full synthesis report"
	@echo "  make resources      - View resource utilization"
	@echo "  make timing         - View timing summary"
	@echo ""
	@echo "Setup:"
	@echo "  make install-deps   - Install Python dependencies"
	@echo "  make check-tools    - Verify required tools are installed"
	@echo ""
	@echo "Examples:"
	@echo "  make flash                           # Build and program"
	@echo "  make image-rom IMAGE=logo.png        # Convert logo to ROM"
	@echo "  make test-pattern && make image-rom IMAGE=test_pattern.png"
