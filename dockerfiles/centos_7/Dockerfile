## ----------------------------------------------------------------------------
## Need nvidia-docker to run https://github.com/NVIDIA/nvidia-docker
## Image from https://gitlab.com/nvidia/cuda/
## FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
FROM nvidia/cuda:10.2-cudnn7-devel-centos7

## ----------------------------------------------------------------------------
#RUN adduser --gecos "Main User" --home /home/owner --disabled-password owner && \
#    usermod -a -G dialout owner && \
#    echo "owner ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99_aptget
    
## ----------------------------------------------------------------------------
RUN yum -y update && yum clean all
RUN yum install -y sudo yum-utils epel-release curl usbutils putty
RUN yum install -y git gcc gcc-c++ cmake3 cmake3-gui qt5-qtbase-devel python3-devel python3-pip
RUN yum install -y gtk2-devel libpng-devel jasper-devel openexr-devel libwebp-devel libjpeg-turbo-devel libtiff-devel libdc1394-devel tbb-devel numpy
RUN yum install -y eigen3-devel gstreamer-plugins-base-devel freeglut-devel mesa-libGL mesa-libGL-devel boost boost-thread boost-devel libv4l-devel
RUN yum install -y openblas-compat

## ----------------------------------------------------------------------------
#RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.3/cmake-3.16.3-Linux-x86_64.sh --no-check-certificate
#RUN chmod +x cmake-3.16.3-Linux-x86_64.sh
#RUN ./cmake-3.16.3-Linux-x86_64.sh --prefix /usr/local/cmake --exclude-subdir --skip-license

    
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
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN sudo python3 get-pip.py

RUN pip3 install -U numpy bokeh launchpadlib pandas Cython contextlib2 pillow lxml jupyter matplotlib opencv-python cffi tqdm


    
## ----------------------------------------------------------------------------
## get the repos
USER owner

RUN cd ~ && \
    mkdir -p dlib && \
    git clone -b 'v19.19' --single-branch https://github.com/davisking/dlib.git dlib/
	
RUN cd ~ && mkdir -p Projects

RUN cd ~/Projects && git clone https://github.com/davemers0160/Common
RUN cd ~/Projects && git clone https://github.com/davemers0160/dfd_common
RUN cd ~/Projects && git clone https://github.com/davemers0160/dlib-contrib
RUN cd ~/Projects && git clone https://github.com/davemers0160/dlib_obj_detector
RUN cd ~/Projects && git clone https://github.com/davemers0160/obj_det_lib

## ----------------------------------------------------------------------------
RUN echo "export PLATFORM=docker" >> /home/ros/.bashrc


## ----------------------------------------------------------------------------
WORKDIR /home/owner
CMD ["bash"]

## ----------------------------------------------------------------------------
## THESE ARE THE COMMANDS TO BUILD THE DOCKER CONTAINER
## ----------------------------------------------------------------------------
# docker build -t cent7 .

## ----------------------------------------------------------------------------
## THIS IS WHERE THE COMMANDS FOR RUNNING THE DOCKER CAONTAINER ARE LOCATED
## ----------------------------------------------------------------------------
# To start the container run the following command
# xhost +local:docker

# docker container run --rm -it --gpus all --name cent7 --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix cent7

## Use this to allow the docker conatiner to be placed on the local network so that other computers on the LAN can access
# docker network create -d macvlan --subnet=10.127.1.0/24 --gateway=10.127.1.1 --ip-range=10.127.1.248/29 -o parent=enp35s0 docker_net
# docker container run --net=docker_net -it --gpus all --name cent7 --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix cent7

# xhost -local:docker

# To get into an existing/open conatainer while it is running execute the following
# docker exec -it cent7 /bin/bash

# This increase the file transfer ability to 1GB for the camera
# sudo sh -c 'echo 1000 > /sys/module/usbcore/parameters/usbfs_memory_mb'
# cat /sys/module/usbcore/parameters/usbfs_memory_mb

# use these to tie in the local host data storage to the docker container
# docker container run -it --gpus all --name cent7 --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/data:/home/owner/data cent7
# docker container run --rm -it --gpus all --name cent7 --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/data:/home/owner/data cent7


