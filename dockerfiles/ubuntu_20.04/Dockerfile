## ----------------------------------------------------------------------------
## Download base image ubuntu 20.04
##FROM nvidia/cuda:11.1-base-ubuntu20.04
FROM ubuntu:20.04

## ----------------------------------------------------------------------------
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y --fix-missing linux-headers-`uname -r`
#RUN apt-get install -y --fix-missing linux-headers-`uname -r`:i386 
RUN apt-get install -y --fix-missing sudo build-essential make bash software-properties-common module-assistant
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt-get install -y --fix-missing gfortran git wget curl nano udev kmod usbutils putty libusb-dev pkg-config iputils-ping libncurses5-dev
#RUN apt-get install -y --fix-missing libatlas-base-dev libavcodec-dev libavformat-dev libgtk2.0-dev libjpeg-dev liblapack-dev libswscale-dev libtiff5-dev libqt4-dev
#RUN apt-get install -y --fix-missing libqt5xml5 libxmu-dev libxi-dev 
RUN apt-get install -y --fix-missing python3-dev python3-numpy unzip 
RUN rm -rf /var/lib/apt/lists/*

## ----------------------------------------------------------------------------
## Install cmake 3.16
#RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.3/cmake-3.16.3-Linux-x86_64.sh --no-check-certificate
#RUN chmod +x cmake-3.16.3-Linux-x86_64.sh
#RUN ./cmake-3.16.3-Linux-x86_64.sh --prefix /usr/local/cmake --exclude-subdir --skip-license

## ----------------------------------------------------------------------------
## get the EDT PDV API for the VisionLink F4 card
RUN apt-get install -y --fix-missing flex bison
RUN wget https://edt.com/wp-content/uploads/2019/07/EDTpdv_lnx_5.5.8.9.run
RUN chmod +x EDTpdv_lnx_5.5.8.9.run 
RUN ./EDTpdv_lnx_5.5.8.9.run -- --default

## These are for the FLIR camera
#RUN apt-get update -y && \
#    apt-get install -y --fix-missing libraw1394-11 libavcodec-dev libavformat-dev libswscale-dev libswresample-dev libavutil-dev \
#    libgtkmm-2.4-dev libglademm-2.4-dev libgtkglextmm-x11-1.2-dev  libcanberra-gtk-module usbutils udev kmod
    
#RUN echo "1000" > /sys/module/usbcore/parameters/usbfs_memory_mb
    
## ----------------------------------------------------------------------------
## Add the user
RUN adduser --system --gecos '' --home /home/owner --disabled-password owner
RUN addgroup owner && \
    #usermod -a -G owner owner && \
    adduser owner owner && \
    adduser owner sudo && \
    adduser owner dialout && \
    echo "owner ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/owner && \
    chmod 0440 /etc/sudoers.d/owner 

RUN chown owner:owner -R /home/owner

## ----------------------------------------------------------------------------
## Python
#RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
#RUN sudo python3 get-pip.py

#RUN pip3 install -U numpy bokeh launchpadlib pandas Cython contextlib2 pillow lxml jupyter matplotlib opencv-python cffi tqdm

## ----------------------------------------------------------------------------
## get the repos
USER owner

#RUN cd ~ && \
#    mkdir -p dlib && \
#    git clone -b 'v19.19' --single-branch https://github.com/davisking/dlib.git dlib-19.19/
	
RUN cd ~ && mkdir -p Projects

RUN cd ~/Projects && git clone https://github.com/davemers0160/Common.git
#RUN cd ~/Projects && git clone https://github.com/davemers0160/dfd_common.git
#RUN cd ~/Projects && git clone https://github.com/davemers0160/dlib-contrib.git
#RUN cd ~/Projects && git clone https://github.com/davemers0160/dlib_object_detection.git

## ----------------------------------------------------------------------------
RUN echo "PATH=\$PATH:/home/owner/.local/bin" >> /home/owner/.bashrc
RUN echo "export PLATFORM=docker" >> /home/owner/.bashrc

## ----------------------------------------------------------------------------
WORKDIR /home/owner
CMD ["bash"]

## ----------------------------------------------------------------------------
## THESE ARE THE COMMANDS TO BUILD THE DOCKER CONTAINER
## ----------------------------------------------------------------------------
# docker build -t u20 .

## ----------------------------------------------------------------------------
## THIS IS WHERE THE COMMANDS FOR RUNNING THE DOCKER CAONTAINER ARE LOCATED
## ----------------------------------------------------------------------------
# To start the container run the following command
# xhost +local:docker
# docker container run -it --gpus all --name u20 --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix u20
# docker container run --rm -it --gpus all --name u20 --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix u20
# xhost -local:docker

# This increase the file transfer ability to 1GB for the camera
# sudo sh -c 'echo 1000 > /sys/module/usbcore/parameters/usbfs_memory_mb'
# cat /sys/module/usbcore/parameters/usbfs_memory_mb

# To get into an existing/open conatainer while it is running execute the following
# docker exec -it u20 /bin/bash

# 
# docker container run -it --gpus all --name u20 --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/data:/home/owner/data u20
# docker container run --rm -it --gpus all --name u20 --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/data:/home/owner/data u20


