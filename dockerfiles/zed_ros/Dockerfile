## ----------------------------------------------------------------------------
## Need nvidia-docker to run https://github.com/NVIDIA/nvidia-docker
## Image from https://gitlab.com/nvidia/cuda/
##FROM nvidia/cudagl:10.0-devel-ubuntu16.04
FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04

## ----------------------------------------------------------------------------
## set up the ability to get out to the rest of the world for app user
#RUN echo 'http_proxy="http://130.163.13.200:8080"' >> /etc/environment
#RUN echo 'https_proxy="http://130.163.13.200:8080"' >> /etc/environment


## ----------------------------------------------------------------------------
## copy the certs forrdtecndproxy01v2.crt the proxies
#ADD rdtecndproxy01v2.crt /usr/local/share/ca-certificates/
#RUN chmod 644 /usr/local/share/ca-certificates/rdtecndproxy01v2.crt
#RUN update-ca-certificates


## ----------------------------------------------------------------------------
## Setup the ZED SDK
# RUN apt-get update -y && apt-get upgrade -y && apt-get autoremove -y
RUN apt-get update -y
RUN apt-get install lsb-release wget less udev sudo apt-transport-https nano cmake usbutils git libusb-dev libturbojpeg -y
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
RUN rm -rf /var/lib/apt/lists/*

## ----------------------------------------------------------------------------
## Get the CUDNN libraries
#ENV CUDNN_VERSION 7.6.4.38

#RUN apt-get update && apt-get install -y --no-install-recommends \
#    libcudnn7=$CUDNN_VERSION-1+cuda10.0 libcudnn7-dev=$CUDNN_VERSION-1+cuda10.0 && \
#    apt-mark hold libcudnn7 && \
#    rm -rf /var/lib/apt/lists/*



## ----------------------------------------------------------------------------
## Get the ZED SDK
RUN apt-get update -y
RUN wget https://stereolabs.sfo2.cdn.digitaloceanspaces.com/zedsdk/2.8/ZED_SDK_Ubuntu16_v2.8.3.run --no-check-certificate
RUN chmod +x ZED_SDK_Ubuntu16_v2.8.3.run
RUN ./ZED_SDK_Ubuntu16_v2.8.3.run silent
RUN rm ZED_SDK_Ubuntu16_v2.8.3.run
RUN rm -rf /var/lib/apt/lists/*
# Make some tools happy
RUN mkdir -p /root/Documents/ZED/


## ----------------------------------------------------------------------------
## Setup ROS
RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' 
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update -y

## ----------------------------------------------------------------------------
# ubuntu 18
# RUN apt-get install ros-melodic-desktop-full python-rosinstall python-rosinstall-generator python-wstool build-essential -y --allow-unauthenticated    
# ubuntu 16
RUN apt-get install ros-kinetic-desktop-full -y --fix-missing
#RUN rm -rf /var/lib/apt/lists/*


## ----------------------------------------------------------------------------
## Add the ros user
RUN adduser --gecos "ROS User" --home /home/ros --disabled-password ros && \
    usermod -a -G dialout ros && \
    echo "ros ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99_aptget && \
    chown ros /usr/local/zed/ -R


## ----------------------------------------------------------------------------
## Install some other packages
RUN apt-get update -y
RUN apt-get install libqt5xml5 libxmu-dev libxi-dev python-rosinstall python-rosinstall-generator python-wstool build-essential python3-dev -y
RUN apt-get install -y ros-kinetic-moveit
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN sudo python get-pip.py
#RUN sudo python3 get-pip.py


## ----------------------------------------------------------------------------
# switch to user ros, but the HOME is still /, not /home/ros
USER ros


RUN pip install launchpadlib pandas Cython contextlib2 pillow lxml jupyter matplotlib utils --user
RUN pip install tensorflow-gpu==1.14 tensorflow_hub --user --ignore-installed


## ----------------------------------------------------------------------------
## setup ros env
#ubuntu 18
#RUN sudo rosdep init && rosdep update && echo "source /opt/ros/melodic/setup.bash\"" >> /home/ros/.bashrc 
#ubuntu 16
RUN sudo rosdep init && rosdep update && echo "source /opt/ros/kinetic/setup.bash" >> /home/ros/.bashrc
RUN mkdir /home/ros/src
RUN mkdir -p /home/ros/catkin_ws
RUN mkdir -p /home/ros/catkin_ws/src
RUN chown -R ros:ros /home/ros

## ----------------------------------------------------------------------------
## get the zed-ros-wrapper
RUN cd /home/ros/catkin_ws/src && \
    git clone -b 'v2.x' --single-branch https://github.com/stereolabs/zed-ros-wrapper.git /home/ros/catkin_ws/src/zed-ros-wrapper
    
## build the zed ros wrapper in the catkin work space
RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash; cd /home/ros/catkin_ws; catkin_make"


## ----------------------------------------------------------------------------
RUN sudo apt-get install -y software-properties-common iputils-ping


## ----------------------------------------------------------------------------
## get the ros tensorflow camera image classification code
RUN cd /home/ros/ && \
    git clone https://github.com/OTL/rostensorflow.git /home/ros/rostensorflow 


## ----------------------------------------------------------------------------
## get the tensorflow object detector code
#RUN cd /home/ros/catkin_ws/src && \
#    git clone https://github.com/mohammedari/tensorflow_object_detector_ros.git tf_obj_det
RUN cd /home/ros/ && \
    git clone https://github.com/tensorflow/models
RUN cd  /home/ros/models/research && \
    wget -O protobuf.zip https://github.com/google/protobuf/releases/download/v3.0.0/protoc-3.0.0-linux-x86_64.zip && \
    unzip protobuf.zip && \
    ./bin/protoc object_detection/protos/*.proto --python_out=.


## ----------------------------------------------------------------------------
## get a couple of object detection models...
RUN cd /home/ros && \
    wget http://download.tensorflow.org/models/object_detection/ssd_resnet50_v1_fpn_shared_box_predictor_640x640_coco14_sync_2018_07_03.tar.gz && \
    tar -xzvf ssd_resnet50_v1_fpn_shared_box_predictor_640x640_coco14_sync_2018_07_03.tar.gz && \
    mv ssd_resnet50_v1_fpn_shared_box_predictor_640x640_coco14_sync_2018_07_03 ssd_resnet50_v1_fpn && \
    rm ssd_resnet50_v1_fpn_shared_box_predictor_640x640_coco14_sync_2018_07_03.tar.gz

RUN cd /home/ros && \    
    wget http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v2_oid_v4_2018_12_12.tar.gz && \    
    tar -xzvf ssd_mobilenet_v2_oid_v4_2018_12_12.tar.gz && \
    mv ssd_mobilenet_v2_oid_v4_2018_12_12 ssd_mobilenet_v2_oid && \    
    rm ssd_mobilenet_v2_oid_v4_2018_12_12.tar.gz
    
RUN cd /home/ros && \ 
    wget http://download.tensorflow.org/models/object_detection/faster_rcnn_inception_resnet_v2_atrous_oid_v4_2018_12_12.tar.gz && \
    tar -xzvf faster_rcnn_inception_resnet_v2_atrous_oid_v4_2018_12_12.tar.gz && \
    mv faster_rcnn_inception_resnet_v2_atrous_oid_v4_2018_12_12 faster_rcnn_inception_resnet_v2_oid && \
    rm faster_rcnn_inception_resnet_v2_atrous_oid_v4_2018_12_12.tar.gz


## ----------------------------------------------------------------------------
## get the custom ros tf object detection code
RUN cd /home/ros && \
    mkdir tf_obj_det && \
    cd tf_obj_det && \
    #wget https://raw.githubusercontent.com/davemers0160/Common/master/python/tf_obj_det_v2.py --no-check-certificate && \
    wget https://raw.githubusercontent.com/davemers0160/robot/master/python_code/ros_tf_obj_det.py --no-check-certificate

RUN sudo usermod -a -G video ros

RUN cd /home/ros/catkin_ws/src && \
    git clone https://github.com/davemers0160/robot.git
    
RUN cd /home/ros && \
    mkdir Projects && \
    cd Projects && \
    git clone https://github.com/davemers0160/Common.git
    
RUN sudo apt-get install -y cmake-gui putty

## ----------------------------------------------------------------------------
## put the tensorflow models into the PYTHONPATH
RUN echo "export PYTHONPATH=\$PYTHONPATH:/home/ros/models:/home/ros/models/research:/home/ros/models/research/slim:/home/ros/models/research/object_detection" >> /home/ros/.bashrc
#RUN echo "sudo chmod 766 /dev/video0" >> /home/ros/.bashrc
RUN echo "PATH=\$PATH:/home/ros/.local/bin" >> /home/ros/.bashrc
RUN echo "source /home/ros/catkin_ws/devel/setup.bash" >> /home/ros/.bashrc
RUN echo "export PLATFORM=docker" >> /home/ros/.bashrc

## ----------------------------------------------------------------------------
# cd /home/ros default
WORKDIR /home/ros

CMD ["bash"]

## ----------------------------------------------------------------------------
## THIS IS WHERE THE COMMANDS FOR RUNNING THE DOCKER CAONTAINER ARE LOCATED
## ----------------------------------------------------------------------------
# To start the container run the following command
# xhost +local:docker
# docker container run --rm -it --gpus all --name zed_ros --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix zed_ros
# xhost -local:docker

# To get into an existing/open conatainer while it is running execute the following
# docker exec -it zed_ros /bin/bash


## ----------------------------------------------------------------------------
## THESE ARE THE COMMANDS TO RUN WHILE IN THE CONTAINER
## ----------------------------------------------------------------------------

# This command starts the ROS environment and must be run for each instance of the container that is opened
# cd /home/ros/catkin_ws/devel/ && source setup.bash && cd /home/ros/


## ----------------------------------------------------------------------------
## to run the ros zed rviz examples from the catkin_ws directory
# cd /home/ros/catkin_ws/src/zed-ros-wrapper/zed_display_rviz
# roslaunch zed_display_rviz display_zed.launch

## ----------------------------------------------------------------------------
## to run the main ROS zed launch execute the following
# cd /home/ros/catkin_ws/src/zed-ros-wrapper/zed_wrapper
# roslaunch launch/zed.launch
# roslaunch /home/ros/catkin_ws/src/zed-ros-wrapper/zed_wrapper/launch/zed.launch

## ----------------------------------------------------------------------------
## ZED Tools
# /usr/local/zed/tools/./"ZED Diagnostic"


## ----------------------------------------------------------------------------
## ROS topic right camera -> /zed/zed_node/right_raw/image_raw_color/compressed
# cd /home/ros/rostensorflow
# python image_recognition.py image:=/zed/zed_node/right_raw/image_raw_color
# rosrun rqt_image_view rqt_image_view /zed/zed_node/right_raw/image_raw_color

# python image_recognition.py image:=/zed/zed_node/rgb_raw/image_raw_color
# rosrun rqt_image_view rqt_image_view /zed/zed_node/rgb_raw/image_raw_color

## ----------------------------------------------------------------------------
## to run the object detection code execute the following
# cd tf_obj_det
# python ros_tf_obj_det.py

## ----------------------------------------------------------------------------
## to run the visualization of the object detections execute the following
# rosrun rqt_image_view rqt_image_view /obj_det/image

## ----------------------------------------------------------------------------
## to view the depth visualization execute the following
# rosrun rqt_image_view rqt_image_view /zed/zed_node/depth/depth_registered

## ----------------------------------------------------------------------------
## to run the object detection code execute the following
# rostopic echo /obj_det/target_razel


