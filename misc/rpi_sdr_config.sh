#!/bin/bash

# -----------------------------------------------------------------------------
# Instructions for this script
# From windows you can sftp into the pi and copy this repo into /home/{$USER}/Projects
# sftp loki@xxx.xxx.xxx.xxx
# 
# wget https://github.com/davemers0160/Common/raw/master/misc/rpi_sdr_config.sh
#
# put this file in the user home directory and then run the following:
# chmod +x rpi_sdr_config.sh
# ./rpi_sdr_config.sh
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# if the script does not run initially you may need to run the following command and then retry the script
# dos2unix rpi_sdr_config.sh
# -----------------------------------------------------------------------------

sudo apt-get update
sudo apt-get install -y build-essential git cmake libusb-1* libsndfile1 libncurses5-dev

# create the python virtual environment and install required packages
python -m venv ~/venv --system-site-packages --symlinks

# create a script to activate the python virtual environment
echo '#!/bin/bash' > activate_venv.sh
echo 'source ~/venv/bin/activate' >> activate_venv.sh
chmod +x ~/activate_venv.sh

# have the venv startup when the terminal starts
echo 'source activate_venv.sh' >> .bashrc

# activate the venv to install some things
source ~/venv/bin/activate
pip install numpy pyyaml soundfile

# grab all of the projects 
mkdir -p Projects
cd Projects

echo " "
echo "Building BladeRF project"
echo " "

git clone https://github.com/Nuand/bladeRF.git ./bladeRF
cd ./bladeRF/host
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DINSTALL_UDEV_RULES=ON ../
make -j 4 && sudo make install && sudo ldconfig

cd ~/Projects

# make the data directory
mkdir -p data

# grab the common, python_common and the rapipyaml repos
git clone https://github.com/davemers0160/Common
git clone https://github.com/davemers0160/python_common

git clone --recursive https://github.com/davemers0160/rapidyaml

echo " "
echo "Building rapidyaml project"
echo " "

# build the rapidyaml library
cd rapidyaml
mkdir build
cd build
cmake -DBUILD_SHARED_LIBS=ON ..
cmake --build . --config Release -- -j4
sudo make install && sudo ldconfig

cd ~/Projects

# clone the SDR library
git clone https://github.com/davemers0160/SDR

# build the tx hop example
cd SDR/bladerf/tx_example
mkdir build
cd build
cmake ..
cmake --build . --config Release -- -j4

# copy the service that will start the bladeRF code
# note: ${USER} in the bladerf.service file will need to be changed to the actual username
sudo cp /home/${USER}/Projects/SDR/bladerf/common/bladerf.service /lib/systemd/system/.

# reload the systemd daemon
sudo systemctl daemon-reload

# enable the bladerf service and autostart
# sudo systemctl enable bladerf.service

echo " "
echo "Run the following command to enable the bladerf automatic start service"
echo "sudo systemctl enable bladerf.service"
echo " "
echo "Run the following command:"
echo "sudo nano /boot/firmware/cmdline.txt"
echo "- add the following to the end of the line: \" usbcore.usbfs_memory_mb=2048 \" "

