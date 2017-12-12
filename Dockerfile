# This Dockerfile creates a custom image based on the locally created
# `ros_kinetic_full_cuda9` image
# For more details on generating the above custom image, see the Dockerfile in 
# the repository available here 
# https://github.com/gandrein/docker_ros_kinetic_cuda9

FROM nvidia/cuda:9.0-devel-ubuntu16.04 

MAINTAINER Andrei Gherghescu <gandrein@gmail.com>

LABEL Description="Customized ROS-Kinetic-Full image with Gazebo 8 and CUDA 9 support for Ubuntu 16.04" Version="1.0"

# Arguments
ARG user=docker
ARG uid=1000
ARG shell=/bin/bash

# ------------------------------------------ Install required (&useful) packages --------------------------------------
RUN apt-get update && apt-get install -y \
software-properties-common python-software-properties \
lsb-release \
mesa-utils \
x11-apps build-essential \
git \
subversion \
nano \
terminator \
gnome-terminal \
wget \
curl \
htop \
python3-pip python-pip  \
gdb valgrind \
zsh screen tree \
sudo ssh synaptic vim \
python-rosdep python-rosinstall \
libcanberra-gtk* \
&& apt-get clean

# Install python pip(s)
RUN sudo -H pip2 install -U pip numpy && sudo -H pip3 install -U pip numpy

# ---------------------------------- ROS-Kinetic Desktop Full Image -----------------------------
# Based on 
# https://github.com/osrf/docker_images/blob/5399f380af0a7735405a4b6a07c6c40b867563bd/ros/kinetic/ubuntu/xenial/desktop-full/Dockerfile

# Install ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN apt-get update && apt-get install -y ros-kinetic-desktop-full \
 	&& rm -rf /var/lib/apt/lists/*

RUN pip install catkin_tools

# ---------------------------------- Gazebo 8  -----------------------------
# Setup osrfoundation repository keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2486D2DD83DB69272AFE98867170598AF249743

# Add osrfoundation repository to sources.list
RUN . /etc/os-release \
    && . /etc/lsb-release \
    && echo "deb http://packages.osrfoundation.org/gazebo/$ID-stable $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/gazebo-latest.list

# Remove Gazebo installed with ROS-Kinetic full
RUN sudo apt-get purge gazebo* -y
RUN sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get install -y \
	gazebo8 \
	ros-kinetic-gazebo8-ros-pkgs \
	ros-kinetic-gazebo8-ros-control \
	&& apt-get clean

# Configure timezone and locale
RUN sudo apt-get clean && sudo apt-get update -y && sudo apt-get install -y locales
RUN sudo locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8


# ---------------------------------- User enviroment config  -----------------------------
# Crete and add user
RUN useradd -ms ${shell} ${user}
ENV USER=${user}

RUN export uid=${uid} gid=${uid}

RUN \
  echo "${user} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${user}" && \
  chmod 0440 "/etc/sudoers.d/${user}"
  RUN chown ${uid}:${uid} -R "/home/${user}"

# Switch to user
USER ${user}

# Install and configure OhMyZSH
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
# RUN chsh -s /usr/bin/zsh ${user}
RUN git clone https://github.com/sindresorhus/pure $HOME/.oh-my-zsh/custom/pure
RUN ln -s $HOME/.oh-my-zsh/custom/pure/pure.zsh-theme $HOME/.oh-my-zsh/custom/
RUN ln -s $HOME/.oh-my-zsh/custom/pure/async.zsh $HOME/.oh-my-zsh/custom/
RUN sed -i -e 's/robbyrussell/refined/g' $HOME/.zshrc

# =============================== Configs ==========================================
# Source ROS setup into .rc files
RUN echo "source /opt/ros/kinetic/setup.sh" >> $HOME/.bashrc
RUN echo "source /opt/ros/kinetic/setup.zsh" >> $HOME/.zshrc
# Configure ROS
RUN sudo rm -rf /etc/ros/rosdep/sources.list.d/*
RUN sudo rosdep init && sudo rosdep fix-permissions && rosdep update 

# Copy custom files 
# NOTE: $HOME does not seem to work with the COPY directive
# Copy Terminator configuration
RUN mkdir -p $HOME/.config/terminator/
COPY config_files/terminator_config /home/${user}/.config/terminator/config

COPY config_files/bash_aliases /home/${user}/.bash_aliases
# Add the bash aliases to zsh rc as well
RUN cat $HOME/.bash_aliases >> $HOME/.zshrc

COPY entrypoint.sh /home/${user}/entrypoint.sh
RUN sudo chmod +x /home/${user}/entrypoint.sh
# Make user the owner of the copied files 
RUN sudo chown -R ${user}:${user} /home/${user}

# Create a mount point to bind host data to
VOLUME /extern

# Make SSH available
EXPOSE 22
# Expose Gazebo port
EXPOSE 11345

# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1

# Make a directory for gazebo
RUN mkdir -p $HOME/.gazebo/

# Create CATKIN workspace folder and ENV variable
RUN mkdir -p home/${user}/catkin_ws
ENV CATKIN_TOPLEVEL_WS=home/${user}/catkin_ws

# Switch to user's HOME folder
WORKDIR /home/${user}

# In the newly loaded container sometimes you can't do `apt install <package>
# unless you do a `apt update` first.  So run `apt update` as last step
# NOTE: bash auto-completion may have to be enabled manually from /etc/bash.bashrc
RUN sudo apt-get update -y

# Using the "exec" form for the Entrypoint command
ENTRYPOINT ["./entrypoint.sh", "terminator"]
CMD ["-e", "echo $INFO_MSG && /usr/bin/zsh"]