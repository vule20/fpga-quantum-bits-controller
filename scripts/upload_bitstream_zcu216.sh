#!/bin/bash

# Define the path to the bitstream file
BUILD_FOLDER="build_5999d8f9_20241202103141"
BITSTREAM_FILE="gateware/top/${USER}_build/${BUILD_FOLDER}/psbd.bit"

# Print the bitstream path for confirmation
echo "Using bitstream file: $BITSTREAM_FILE"

# Check if the bitstream file exists
if [ ! -f "$BITSTREAM_FILE" ]; then
  echo -e "\e[31mError: Bitstream file '$BITSTREAM_FILE' not found!\e[0m"
  exit 1
fi

# Run Vivado in interactive mode to keep the session open for logging
vivado -mode tcl <<EOF
open_hw_manager
puts "Hardware manager opened."

connect_hw_server
puts "Connected to hardware server."

open_hw_target
puts "Hardware target opened."

set hw_device [lindex [get_hw_devices] 0]
puts "Using hardware device: \$hw_device"

refresh_hw_device \$hw_device
puts "Hardware device refreshed."

set_property PROGRAM.FILE {$BITSTREAM_FILE} \$hw_device
program_hw_devices \$hw_device
puts "Bitstream successfully uploaded to FPGA."

# Keep session alive for inspection
puts "Press Ctrl+C to exit Vivado session."
vwait forever
EOF