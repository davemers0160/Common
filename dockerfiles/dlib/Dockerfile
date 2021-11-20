## ----------------------------------------------------------------------------
## Need nvidia-docker to run https://github.com/NVIDIA/nvidia-docker
## Image from https://gitlab.com/nvidia/cuda/
#FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04
FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

## ----------------------------------------------------------------------------
## set up the ability to get out to the rest of the world for app user
#RUN echo 'http_proxy="http://130.163.13.200:8080"' >> /etc/environment
#RUN echo 'https_proxy="http://130.163.13.200:8080"' >> /etc/environment
#RUN echo 'HTTP_PROXY="http://130.163.13.200:8080"' >> /etc/environment
#RUN echo 'HTTPS_PROXY="http://130.163.13.200:8080"' >> /etc/environment

#RUN echo "export http_proxy=http://130.163.13.200:8080/" > /etc/profile.d/http_proxy.sh
#RUN echo "export https_proxy=http://130.163.13.200:8080/" >> /etc/profile.d/http_proxy.sh

#RUN echo "proxy=http://130.163.13.200:8080" >> /etc/yum.conf

## copy the certs forrdtecndproxy01v2.crt the proxies
#ADD rdtecndproxy01v2.crt /etc/pki/ca-trust/source/anchors/
#RUN chmod 644 /etc/pki/ca-trust/source/anchors/rdtecndproxy01v2.crt
#RUN update-ca-certificates

  
## ----------------------------------------------------------------------------
#RUN adduser --gecos "Main User" --home /home/owner --disabled-password owner && \
#    usermod -a -G dialout owner && \
#    echo "owner ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99_aptget
    
## ----------------------------------------------------------------------------
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y --fix-missing sudo build-essential gfortran git wget curl nano libatlas-base-dev libavcodec-dev libavformat-dev libgtk2.0-dev libjpeg-dev liblapack-dev libswscale-dev pkg-config
RUN apt-get install -y --fix-missing iputils-ping libqt5xml5 libxmu-dev libxi-dev python3-dev python3-numpy
RUN rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.3/cmake-3.16.3-Linux-x86_64.sh --no-check-certificate
RUN chmod +x cmake-3.16.3-Linux-x86_64.sh
RUN ./cmake-3.16.3-Linux-x86_64.sh --prefix /usr/local/cmake --exclude-subdir --skip-license

## These are for the FLIR camera
RUN apt-get update -y && \
    apt-get install -y --fix-missing libraw1394-11 libavcodec-dev libavformat-dev libswscale-dev libswresample-dev libavutil-dev \
    libgtkmm-2.4-dev libglademm-2.4-dev libgtkglextmm-x11-1.2-dev libusb-dev libcanberra-gtk-module usbutils udev kmod
    
#RUN echo "1000" > /sys/module/usbcore/parameters/usbfs_memory_mb
    
## ----------------------------------------------------------------------------
## Add the user
RUN adduser --system --gecos '' --home /home/owner --disabled-password owner && \
    addgroup owner && \
    #usermod -a -G owner owner && \
    adduser owner owner && \
    adduser owner sudo && \
    adduser owner dialout && \
    echo "owner ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/owner && \
    chmod 0440 /etc/sudoers.d/owner 

RUN chown owner:owner -R /home/owner

## ----------------------------------------------------------------------------
#RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
#RUN sudo python3 get-pip.py

#RUN pip3 install -U numpy bokeh launchpadlib pandas Cython contextlib2 pillow lxml jupyter matplotlib opencv-python cffi tqdm

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils tzdata && \
    apt-get install -y --fix-missing putty libcanberra-gtk-module libcanberra-gtk3-module libopencv-dev
    
## ----------------------------------------------------------------------------
## get the repos
USER owner

RUN cd ~ && \
    git clone -b 'v19.19' --single-branch https://github.com/davisking/dlib.git dlib-19.19/
	
RUN cd ~ && mkdir -p Projects

RUN cd ~/Projects && git clone https://github.com/davemers0160/Common.git
RUN cd ~/Projects && git clone https://github.com/davemers0160/dfd_common.git
RUN cd ~/Projects && git clone https://github.com/davemers0160/dlib-contrib.git
RUN cd ~/Projects && git clone https://github.com/davemers0160/dlib_object_detection.git

## ----------------------------------------------------------------------------
## copy the flycapture install files from the PC to the image
## This requires that the file be downloaded first and placed into the same directory as this
#ADD flycapture2-2.13.3.31-amd64-pkg_Ubuntu16.04.tgz /home/owner/
#ADD flycapture2-2.13.3.31-amd64-pkg_Ubuntu18.04.tgz /home/owner/
#ADD spinnaker-1.27.0.48-Ubuntu16.04-amd64-pkg.tar.gz /home/owner/
#ADD spinnaker-1.27.0.48-Ubuntu18.04-amd64-pkg.tar.gz /home/owner/

## ----------------------------------------------------------------------------
RUN echo "PATH=\$PATH:/home/owner/.local/bin" >> /home/owner/.bashrc
RUN echo "export PLATFORM=docker" >> /home/owner/.bashrc

## ----------------------------------------------------------------------------
WORKDIR /home/owner
CMD ["bash"]

## ----------------------------------------------------------------------------
## THESE ARE THE COMMANDS TO BUILD THE DOCKER CONTAINER
## ----------------------------------------------------------------------------
# docker build -t dlib_docker .

## ----------------------------------------------------------------------------
## THIS IS WHERE THE COMMANDS FOR RUNNING THE DOCKER CAONTAINER ARE LOCATED
## ----------------------------------------------------------------------------
# To start the container run the following command
# xhost +local:docker

# To run the docker container, attached to gpus and then remain running after the docker is closed.  Use docker commit to make changes permanent
# docker container run -it --gpus all --name dlib_docker --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix dlib_docker

# To run the docker container, attached to gpus and then close after the docker is closed (changes won't be permanent)
# docker container run --rm -it --gpus all --name dlib_docker --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix dlib_docker

# To run the docker container, attached to gpus and then remain running after the docker is closed.  Additional line adds capability to link to external data.
# docker container run -it --gpus all --name dlib_docker --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/data:/home/owner/data dlib_docker

# xhost -local:docker

# This increase the file transfer ability to 1GB for the camera
# sudo sh -c 'echo 1000 > /sys/module/usbcore/parameters/usbfs_memory_mb'
# cat /sys/module/usbcore/parameters/usbfs_memory_mb

# To get into an existing/open conatainer while it is running execute the following
# docker exec -it dlib_docker /bin/bash

#RUN mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

