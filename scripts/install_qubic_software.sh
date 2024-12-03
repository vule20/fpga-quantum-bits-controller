#!/bin/bash

# install anaconda3 if it is not installed yet
install_conda() {
    if command -v conda &> /dev/null; then
        echo "Conda is already installed. You can start using Conda now!"
    else
        echo "Conda is not installed. Proceeding with installation..."

        # install preacquisites for anaconda
        sudo apt-get install libgl1-mesa-glx libegl1-mesa libxrandr2 \
            libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 \
            libxi6 libxtst6

        INSTALLER_URL="https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh"
        INSTALLER_SCRIPT="Anaconda3-2024.10-1-Linux-x86_64.sh"

        # Download the installer
        echo "Downloading Miniconda installer..."
        wget $INSTALLER_URL -O $INSTALLER_SCRIPT

        # Make the script executable
        chmod +x $INSTALLER_SCRIPT

        echo "Installing Miniconda..."
        bash $INSTALLER_SCRIPT -b -p "$HOME/anaconda3"

        # Add Conda to the PATH
        echo "Configuring Conda..."
        eval "$($HOME/anaconda3/bin/conda shell.bash hook)"
        echo "export PATH=\"$HOME/anaconda3/bin:\$PATH\"" >> ~/.bashrc
        source ~/.bashrc

        # Initialize Conda
        conda init

        # Clean up
        rm -f $INSTALLER_SCRIPT

        echo "Anaconda3 installation completed. Please restart your terminal or run 'source ~/.bashrc' to use Conda."
    fi
}

# Function to install a conda environment for qubic
create_qubic_env() {
    if conda env list | grep -q 'qubic'; then
        echo "Environment 'qubic' already exists, skipping creation."
    else
        # Create the environment with Python 3.12
        echo "Creating 'qubic' environment with Python 3.12..."
        conda create --name qubic python=3.12 -y
    fi
}

# Validate input and execute installation
case $1 in
    host)
        echo "Configuring for HOST machine..."
        install_conda
        create_qubic_env
        source ~/.bashrc
        conda activate qubic
        pip install distributed_processor/python --no-cache
        pip install chipcalibration/ qubitconfig/ software/ --no-cache
        pip install jupyter --no-cache
        ;;
    client)
        echo "Configuring for CLIENT machine..."
        sudo pip install -e distributed_processor/python
        sudo cp software/scripts/qubic_rpc_server.service /etc/systemd/system
	
        echo "Installation complete. Current Python version:"
        python --version

        cp software/scripts/server_config.yaml ~/
        
        # use host name instead of static IP4 to avoid having to search for IP
    	# and manually update. In DNS, IP4 will automatically found by
    	# referring to the computer host name
        CLIENT_IP4=$HOSTNAME
        
        # change the IP address in the configuration file to the current IP4 of the FPGA board
        sed -i "s/^ip: .*/ip: $CLIENT_IP4/" ~/server_config.yaml

	    echo "Running qubic server with systemctl. Use journalctl --follow -u qubic_rpc_server to track for real time logs"
        sudo cp software/scripts/start_qubic_server.sh /usr/local/bin/
        sudo systemctl start qubic_rpc_server
        ;;
    *)
        echo -e "\e[31mUsage: $0 {host|client}\e[0m"
        exit 1
        ;;
esac

