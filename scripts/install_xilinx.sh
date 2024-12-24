#!/bin/sh
#SBATCH --job-name=install-vivado
#SBATCH --partition=cpu
#SBATCH --ntasks=1
#SBATCH --mem=32G
#SBATCH --cpus-per-task=16
#SBATCH --time=48:00:00
#SBATCH --output=vivado_log_%x.%j.out
#SBATCH --error=vivado_log_%x.%j.err

cd /work/pi_phuc_umass_edu/vdle_umass_edu/tools/
./xsetup -b Install -a XilinxEULA,3rdPartyEULA -c ~/.Xilinx/install_config.txt
