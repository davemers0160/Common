FROM centos:6.8
ENV container docker

## ----------------------------------------------------------------------------

RUN yum -y update && yum clean all
RUN yum install -y sudo yum-utils epel-release 
RUN yum install -y git gcc gcc-c++ cmake3 cmake3-gui qt5-qtbase-devel python python-devel python-pip cmake python-devel python34-numpy
RUN yum install -y gtk2-devel libpng-devel jasper-devel openexr-devel libwebp-devel libjpeg-turbo-devel libtiff-devel libdc1394-devel tbb-devel numpy
RUN yum install -y eigen3-devel gstreamer-plugins-base-devel freeglut-devel mesa-libGL mesa-libGL-devel boost boost-thread boost-devel libv4l-devel

## ----------------------------------------------------------------------------
## Add the user
RUN useradd --system --create-home --shell /bin/bash owner

    #groupadd -r owner && useradd -g owner owner && \
    #addgroup owner && \
    #adduser owner owner && \
RUN useradd -G owner sudo && \
    useradd -g owner dialout && \
    echo "owner ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/owner && \
    chmod 0440 /etc/sudoers.d/owner 

USER owner

RUN chown owner:owner -R /home/owner




## ----------------------------------------------------------------------------
WORKDIR /home/owner
CMD ["bash"]


## ----------------------------------------------------------------------------
## THESE ARE THE COMMANDS TO BUILD THE DOCKER CONTAINER
## ----------------------------------------------------------------------------
# docker build -t centos .

## ----------------------------------------------------------------------------
## THIS IS WHERE THE COMMANDS FOR RUNNING THE DOCKER CAONTAINER ARE LOCATED
## ----------------------------------------------------------------------------
# To start the container run the following command
# xhost +local:docker
# docker container run --rm -it --gpus all --name centos --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix centos
# xhost -local:docker
