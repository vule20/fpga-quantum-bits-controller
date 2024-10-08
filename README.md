# qubic

## Preacquisite
First, you have to install Vivado Enterprise so that it supports all IP cores needed for the gateware synthesis. If you're installing Vivado Enterprise with batch mode (using terminal on a remote server), you might follow my instructions to save time reading from AMD.

* Register and Download [!https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2022.1_0420_0327_Lin64.bin](the Unified Vivado version 2022.1) from ADM. Then run this command to extract the `xsetup` for Vivado:
```bash
chmod +x ./Xilinx_Unified_2022.1_0420_0327_Lin64.bin
./Xilinx_Unified_2022.1_0420_0327_Lin64.bin  --keep --noexec --target ~/tools/Xilinx
```

If you want to install Vivado on the root folder so that other users can use, you should install it to the `/tools` folder:
```bash
sudo ./Xilinx_Unified_2022.1_0420_0327_Lin64.bin  --keep --noexec --target /tools/Xilinx
```

For my case, I installed it in my home folder, which is `~/tools/Xilinx`

Ater the extraction has finished, navigate to `~/tools/Xilinx` and run authentication & configuration setups as well accepting agreement for final installation.
```bash
cd ~/tools/Xilinx
./xsetup -b AuthTokenGen  # put your AMD email and password there
```

Now, you have to obtain a configuration file and edit it. Run the `./xsetup -b ConfigGen` command, then choose 2 (Vivado), followed by 2 (Vivado ML Enterprise). A configuration file will be then generated at ~/.Xilinx/install_config.txt, go and edit the Destination to your local folder (Destination=/home/your_username/tools/Xilinx).

Finally, run this command and wait for the installation to finish:
```bash
./xsetup -b Install -a XilinxEULA,3rdPartyEULA -c ~/.Xilinx/install_config.txt
```

## Installing drivers for peripherals on Linux
By default, it seems that JTAG cable can't be detected by vivado. If you connect an FPGA board and a JTAG cable to upload bitstream fils to the board, the cable may not be detected.

First, open Vivado in tcl mode by running `vivado -mode tcl` in the bash terminal, make sure the jtag cable (usb-micro-usb) is connected to the host computer (`lsusb` to check), then execute these commands in `Vivado TCL shell` to check if JTAG is detected by Vivado:
```tcl
open_hw_manager
connect_hw_server
get_hw_targets
```

If it outputs something like this:
```tcl
Vivado% get_hw_targets                                   
ERROR: [Labtoolstcl 44-199] No matching targets found on connected servers: localhost
Resolution: If needed connect the desired target to a server and use command refresh_hw_server. Then rerun the get_hw_targets command.
ERROR: [Common 17-39] 'get_hw_targets' failed due to earlier errors.                                                                         
Vivado% refresh_hw_server                                                                                                                    
WARNING: [Labtoolstcl 44-27] No hardware targets exist on the server [localhost:3121]      
Check to make sure the cable targets connected to this machine are properly connected
and powered up, then use the refresh_hw_server command to re-register the hardware targets.
Vivado% get_hw_targets                                                                                                                       
ERROR: [Labtoolstcl 44-199] No matching targets found on connected servers: localhost
Resolution: If needed connect the desired target to a server and use command refresh_hw_server. Then rerun the get_hw_targets command.
ERROR: [Common 17-39] 'get_hw_targets' failed due to earlier errors.
Vivado% disconnect_hw_server                                                                                                                 
Vivado% connect_hw_server                                             
```

Chances are drivers are not installed by default, to install drivers, you have to navigate to the `install_drivers` folder and run the installation script:
```bash
cd ~/tools/Xilinx/Vivado/2022.1/data/xicom/cable_drivers/lin64/install_script/install_drivers
sudo ./install_drivers
./setup_pcusb
```

Now if you run the TCL commands for checking JTAG, you should be able to see it in Vivado:
```tcl
Vivado% refresh_hw_server           
WARNING: [Labtoolstcl 44-27] No hardware targets exist on the server [localhost:3121]
Check to make sure the cable targets connected to this machine are properly connected
and powered up, then use the refresh_hw_server command to re-register the hardware targets.
Vivado% disconnect_hw_server
Vivado% connect_hw_server                                              
INFO: [Labtools 27-2285] Connecting to hw_server url TCP:localhost:3121
INFO: [Labtools 27-3415] Connecting to cs_server url TCP:localhost:3042
INFO: [Labtools 27-3414] Connected to existing cs_server.
localhost:3121
Vivado% get_hw_targets                                                 
localhost:3121/xilinx_tcf/Xilinx/96234996810A
Vivado%
```