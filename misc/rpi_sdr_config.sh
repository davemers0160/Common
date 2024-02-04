#!/bin/bash

sudo apt-get update
sudo apt-get install -y build-essential git cmake libusb-1*

mkdir Projects
cd Projects


git clone https://github.com/Nuand/bladeRF.git ./bladeRF
cd ./bladeRF/host
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DINSTALL_UDEV_RULES=ON ../
make -j 4 && sudo make install && sudo ldconfig

cd ~/Projects

mkdir data

# grab the common repo and the rapipyaml repo
git clone https://github.com/davemers0160/Common
git clone --recursive https://github.com/davemers0160/rapidyaml

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
cd SDR/bladerf/tx_hop_example
mkdir build
cd build
cmake ..
cmake --build . --config Release -- -j4

# copy the service that will start the bladeRF code
sudo cp /home/${USER}/Projects/SDR/bladerf/tx_hop_example/bladerf.service /lib/systemd/system/.

# reload the systemd daemon
systemctl daemon-reload

# enable the bladerf serrvice and autostart
systemctl enable bladerf.service


