## ----------------------------------------------------------------------------
## Need nvidia-docker to run https://github.com/NVIDIA/nvidia-docker
## Image from https://gitlab.com/nvidia/cuda/
FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04


RUN apt-get -y update
RUN apt-get install -y --fix-missing build-essential cmake gfortran git wget curl nano libatlas-dev libavcodec-dev libavformat-dev libgtk2.0-dev libjpeg-dev liblapack-dev libswscale-dev pkg-config
RUN apt-get install -y --fix-missing iputils-ping libqt5xml5 libxmu-dev libxi-dev python3-dev python3-numpy
RUN rm -rf /var/lib/apt/lists/*

RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN sudo python3 get-pip.py

RUN pip install numpy bokeh launchpadlib pandas Cython contextlib2 pillow lxml jupyter matplotlib opencv-python cffi tqdm --user

RUN cd ~ && \
    mkdir -p dlib && \
    git clone -b 'v19.19' --single-branch https://github.com/davisking/dlib.git dlib/
	
RUN cd ~ && mkdir -p Projects

RUN cd ~/Projects && git clone https://github.com/davemers0160/Common
RUN cd ~/Projects && git clone https://github.com/davemers0160/dfd_common
RUN cd ~/Projects && git clone https://github.com/davemers0160/dlib-contrib
RUN cd ~/Projects && git clone https://github.com/davemers0160/dlib_obj_detector
