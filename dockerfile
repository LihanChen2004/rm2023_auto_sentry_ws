FROM ros:noetic-ros-base

ENV DEBIAN_FRONTEND=noninteractive

# 小鱼一键换源
RUN apt update \ 
    && apt install wget python3-yaml -y  \
    && echo "chooses:\n" > fish_install.yaml \
    && echo "- {choose: 5, desc: '一键配置:系统源(更换系统源,支持全版本Ubuntu系统)'}\n" >> fish_install.yaml \
    && echo "- {choose: 2, desc: 更换系统源并清理第三方源}\n" >> fish_install.yaml \
    && echo "- {choose: 1, desc: 添加ROS/ROS2源}\n" >> fish_install.yaml \
    && wget http://fishros.com/install  -O fishros && /bin/bash fishros \
    && rm -rf /var/lib/apt/lists/*  /tmp/* /var/tmp/* \
    && apt-get clean && apt autoclean 

# 初始化 rosdepc
RUN apt-get update && apt-get install git python3-pip -y && \
    pip install rosdepc && \
    sudo rosdepc init  && \
    rosdepc update

# clone projects
RUN git clone https://mirror.ghproxy.com/https://github.com/LihanChen2004/rm2023_auto_sentry_ws.git

# create workspace
WORKDIR /rm2023_auto_sentry_ws/

# install dependencies and some tools
RUN rosdepc install -r --from-paths src --ignore-src --rosdistro $ROS_DISTRO -y && \
    apt-get install wget -y && \
    apt-get install htop -y && \
    apt-get install vim -y && \
    apt-get install ros-noetic-tf -y && \
    apt-get install ros-noetic-robot-localization -y && \
    apt-get install ros-noetic-navigation -y && \
    apt-get install ros-noetic-pcl-conversions -y && \
    apt-get install ros-noetic-pcl-ros -y && \
    apt-get install ros-noetic-gazebo* -y && \
    apt-get install ros-noetic-xacro -y && \
    apt-get install ros-noetic-robot-state-publisher -y && \
    apt-get install ros-noetic-joint-state-publisher -y && \
    apt-get install ros-noetic-rviz -y && \
    rm -rf /var/lib/apt/lists/*

# setup zsh
RUN sh -c "$(wget -O- https://mirror.ghproxy.com/https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
    -t jispwoso -p git \
    -p https://mirror.ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions \
    -p https://mirror.ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting && \
    chsh -s /bin/zsh && \
    rm -rf /var/lib/apt/lists/*

# build
RUN . /opt/ros/noetic/setup.sh && catkin_make

# setup .zshrc
RUN echo "export TERM=xterm-256color" >> /root/.zshrc && \
    echo "setopt no_nomatch # In order to use command with '*'" >> /root/.zshrc && \
    echo "source /rm2023_auto_sentry_ws/devel/setup.sh" >> /root/.zshrc

# source entrypoint setup
RUN sed --in-place --expression \
    '$isource "/rm2023_auto_sentry_ws/devel/setup.sh"' \
    /ros_entrypoint.sh