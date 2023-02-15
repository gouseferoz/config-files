#!/bin/bash
echo "Starting the script..."

cd ~
echo "Download the config files from GITHUB"

# clone the config-files from gouseferoz github
git clone https://github.com/gouseferoz/config-files.git


sed -i -e 's/\r$//' /root/config-files/install_piston.sh

echo "Running the Installation Script"

. /root/config-files/install_piston.sh