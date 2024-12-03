# Get the bitstream file passed from Bash script
set BITSTREAM_FILE [lindex $argv 0]

# Print the bitstream path for confirmation
puts "Using bitstream file: $BITSTREAM_FILE"

# Check if the bitstream file exists
if {![file exists $BITSTREAM_FILE]} {
    puts "Error: Bitstream file '$BITSTREAM_FILE' not found!"
    exit 1
}

# Open the hardware manager
open_hw_manager
puts "Hardware manager opened."

# Connect to the hardware server
connect_hw_server
puts "Connected to hardware server."

# Open the hardware target
open_hw_target
puts "Hardware target opened."

# Get the first available hardware device
set hw_device [lindex [get_hw_devices] 0]

# Refresh the hardware device
refresh_hw_device $hw_device
puts "Hardware device refreshed: $hw_device"

# Set the bitstream file property
set_property PROGRAM.FILE $BITSTREAM_FILE $hw_device

# Program the FPGA
program_hw_devices $hw_device
if {[catch {program_hw_devices $hw_device} result]} {
    puts "Error: Failed to program FPGA. $result"
    exit 1
} else {
    puts "Bitstream successfully uploaded to FPGA."
}

# Close the hardware manager
close_hw_manager
puts "Hardware manager closed."

# Exit the script
exit 0