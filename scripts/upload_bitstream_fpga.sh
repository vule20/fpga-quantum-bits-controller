#!/bin/bash

LOG_FOLDER="./logs"
LOG_FILE="$LOG_FOLDER/vivado.log"
mkdir -p $LOG_FOLDER

# Check if an argument is passed for the bitstream file
if [ -z "$1" ]; then
    # No argument passed, then list all available bitstream files for users to choose from
    BASE_DIR="gateware/top/${USER}_build"

    # Find all directories, extract creation dates, and sort them
    sorted_dirs=$(find "$BASE_DIR" -maxdepth 1 -type d -name "build_*" | awk -F'_' '{print $NF, $0}' | sort -n | awk '{print $2}')

    # Initialize options list
    options=()
    echo "Available .bit files for upload (sorted by creation date):"

    # Loop through sorted directories and collect .bit files
    index=1
    for dir in $sorted_dirs; do
        # Check if .bit files exist in the directory
        for file in "$dir"/*.bit; do
            if [ -f "$file" ]; then
                options+=("$file")
                echo "$index: $file"
                ((index++))
            fi
        done
    done

    # Check if there are any options
    if [ ${#options[@]} -eq 0 ]; then
        echo "No .bit files found."
        exit 1
    fi

    # Ask the user to select a file
    echo
    read -p "Select a file to upload (enter the number): " choice

    # Validate the user's choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
        BITSTREAM_FILE="${options[$((choice - 1))]}"
        echo "You selected: $BITSTREAM_FILE"
    else
        echo "Invalid selection. Exiting."
        exit 1
    fi

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
