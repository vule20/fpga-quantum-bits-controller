#!/bin/bash

LOG_FOLDER="./logs"
LOG_FILE="$LOG_FOLDER/vivado.log"
mkdir -p $LOG_FOLDER

# Check if an argument is passed for the bitstream file
if [ -z "$1" ]; then
    # No argument passed, set default bitstream file location
    BUILD_FOLDER="build_5999d8f9_20241202103141"
    BITSTREAM_FILE="gateware/top/${USER}_build/${BUILD_FOLDER}/psbd.bit"
    echo "No bitstream file provided. Using default: $BITSTREAM_FILE"
else
    # Argument passed, use it as the bitstream file
    BITSTREAM_FILE="$1"
    echo "Using bitstream file: $BITSTREAM_FILE"
fi

# Check if the bitstream file exists
if [ ! -f "$BITSTREAM_FILE" ]; then
    echo "Error: Bitstream file '$BITSTREAM_FILE' not found!"
    exit 1
fi

# Run Vivado with the TCL script to upload the bitstream
vivado -log "$LOG_FOLDER/vivado.log" -journal "$LOG_FOLDER/vivado.jou" -mode batch -source scripts/upload_bitstream.tcl -tclargs "$BITSTREAM_FILE"  