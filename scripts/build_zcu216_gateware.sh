#!/bin/bash

# Ask the user whether to build the latest commit or stay on the current commit
read -p "Do you want to build the latest commit of all submodules? (yes/no): " choice

if [[ "$choice" == "yes" ]]; then
    echo "Updating all submodules to the latest commit..."
    git submodule update --init --recursive --remote
    echo "Submodules updated to the latest commit."
else
    echo "Building submodules at their current commit..."
    git submodule update --init --recursive
    echo "Submodules are now at their current commit."
fi

# Check the current Vivado version
vivado_version=$(vivado -version 2>/dev/null | grep -oP '(?<=Vivado v)\d+\.\d+')

# Check if Vivado is not 2022.1
if [[ "$vivado_version" != "2022.1" ]]; then
    # Display a red warning message
    echo -e "\e[31mWARNING: The current Vivado version is $vivado_version. Please use Vivado 2022.1.\e[0m"
else
    echo "Vivado version 2022.1 is correctly installed."
fi

cd gateware/top
git submodule update --init --recursive
./initialize_build.sh "${USER}_build"

cd "${USER}_build"
./configure_build.sh dsp_config.yaml

# get the latest build folder
BUILD_FOLDER=$(find . -type d -name 'build_*' -printf '%T@ %p\n' | sort -nr | head -n 1 | cut -d' ' -f2)
cd $BUILD_FOLDER

# the new build script depends on gitpython
pip install gitpython
make pre
make

echo "Finish synthesis. Now upload the synthesized hardware to FPGA"

BITSTREAM_FILE="gateware/top/${USER}_build/${BUILD_FOLDER}/psbd.bit"

echo "Bitstream file location ${BITSTREAM_FILE}"

bash scripts/upload_bitstream_zcu216.sh $BITSTREAM_FILE
