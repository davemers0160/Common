## ----------------------------------------------------------------------------
## Need nvidia-docker to run https://github.com/NVIDIA/nvidia-docker
## Image from https://gitlab.com/nvidia/cuda/
## FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
FROM nvidia/cuda:10.2-cudnn7-devel-centos7

## ----------------------------------------------------------------------------
## set up the ability to get out to the rest of the world for app user
RUN echo 'http_proxy="http://130.163.13.200:8080"' >> /etc/environment
RUN echo 'https_proxy="http://130.163.13.200:8080"' >> /etc/environment
RUN echo 'HTTP_PROXY="http://130.163.13.200:8080"' >> /etc/environment
RUN echo 'HTTPS_PROXY="http://130.163.13.200:8080"' >> /etc/environment

RUN echo "export http_proxy=http://130.163.13.200:8080/" > /etc/profile.d/http_proxy.sh
RUN echo "export https_proxy=http://130.163.13.200:8080/" >> /etc/profile.d/http_proxy.sh

RUN echo "proxy=http://130.163.13.200:8080" >> /etc/yum.conf

## copy the certs forrdtecndproxy01v2.crt the proxies
ADD rdtecndproxy01v2.crt /etc/pki/ca-trust/source/anchors/
RUN chmod 644 /etc/pki/ca-trust/source/anchors/rdtecndproxy01v2.crt
RUN update-ca-trust extract

  
## ----------------------------------------------------------------------------
## install all of the required libraries/packages
RUN yum -y update && yum clean all
RUN yum install -y sudo nano curl git yum-utils

# this fixes a flaw in the epel repo pointing
RUN yum install -y epel-release
ADD epel.repo /etc/yum.repos.d/
RUN yum -y update
RUN yum install -y eigen3-devel cmake3 cmake3-gui putty usbutils openblas-devel lapack-devel

RUN yum install -y git gcc gcc-c++ make qt5-qtbase-devel python3-devel python3-pip
RUN yum install -y gtk2-devel libpng-devel jasper-devel openexr-devel libwebp-devel libjpeg-turbo-devel libtiff-devel libdc1394-devel tbb-devel numpy
RUN yum install -y gstreamer-plugins-base-devel freeglut-devel mesa-libGL mesa-libGL-devel boost boost-thread boost-devel libv4l-devel
RUN yum install -y bzip2 wget gcc gcc-c++ gmp-devel mpfr-devel libmpc-devel

RUN rm -rf /var/lib/rpm/__db*


## ----------------------------------------------------------------------------
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN python3 get-pip.py

RUN pip3 install -U numpy bokeh launchpadlib pandas Cython contextlib2 pillow lxml jupyter matplotlib opencv-python cffi tqdm

    
## ----------------------------------------------------------------------------
## Add the user
    
RUN useradd --system --create-home --shell /bin/bash owner    

RUN useradd -G owner sudo
RUN useradd -g owner dialout
RUN echo "owner ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/owner && \
    chmod 0440 /etc/sudoers.d/owner 
    
USER owner

RUN chown owner:owner -R /home/owner

## ----------------------------------------------------------------------------
## get the repos
RUN cd ~ && \
    mkdir -p dlib && \
    git clone -b 'v19.19' --single-branch https://github.com/davisking/dlib.git dlib-19.19
	
RUN cd ~ && mkdir -p Projects

RUN cd ~/Projects && git clone https://github.com/davemers0160/Common.git
RUN cd ~/Projects && git clone https://github.com/davemers0160/dfd_common.git
RUN cd ~/Projects && git clone https://github.com/davemers0160/dlib-contrib.git
RUN cd ~/Projects && git clone https://github.com/davemers0160/dlib_object_detection.git


## ----------------------------------------------------------------------------
## install opencv
RUN cd ~ && mkdir ~/opencv_build && cd ~/opencv_build && \
    git clone https://github.com/opencv/opencv.git && \
    git clone https://github.com/opencv/opencv_contrib.git
    cd ~/opencv_build/opencv && mkdir build && cd build && \
#    cmake3 -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D WITH_TBB=ON -D WITH_V4L=ON -D OPENCV_GENERATE_PKGCONFIG=ON -D WITH_QT=ON -D WITH_OPENGL=ON -D OPENCV_EXTRA_MODULES_PATH=~/opencv_build/opencv_contrib/modules -D ENABLE_CXX11=ON -D BUILD_EXAMPLES=ON ..

#RUN cd ~/opencv_build/opencv/build && make -j10 && \
#    sudo make install && \
#    sudo ln -s /usr/local/lib64/pkgconfig/opencv4.pc /usr/share/pkgconfig/ && \
#    sudo ldconfig



## ----------------------------------------------------------------------------
RUN echo "PATH=\$PATH:/home/owner/.local/bin" >> /home/owner/.bashrc
RUN echo "export PLATFORM=docker" >> /home/owner/.bashrc

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

# use these to tie in the local host data storage to the docker container
# docker container run -it --gpus all --name cent7 --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/data:/home/owner/data cent7
# docker container run --rm -it --gpus all --name cent7 --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/data:/home/owner/data cent7

# xhost -local:docker

# To get into an existing/open conatainer while it is running execute the following
# docker exec -it cent7 /bin/bash


# This increase the file transfer ability to 1GB for the camera
# sudo sh -c 'echo 1000 > /sys/module/usbcore/parameters/usbfs_memory_mb'
# cat /sys/module/usbcore/parameters/usbfs_memory_mb

# do this to fix an epel-release problem
# In /etc/yum.repos.d/epel.repo, commented out the following lines;
# #mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch
# Enabled baseurl lines in configuration file and repointed to new repo.
# baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch

