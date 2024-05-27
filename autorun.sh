image_name=lihanchen2004/rm2023_auto_sentry:latest
instance_name=rm2023_auto_sentry

check_docker_instance_already_running() {
    if  [ ! "$(docker ps -a | grep $instance_name)" ]; then
        return 0
    fi
    return 1
}

delete_running_docker_instance() {
    if ! docker container rm --force "${instance_name}"; then
        return 1
    fi
    return 0
}

# Build from dockerfile if needed:
# docker build -t $image_name . 

simulation_main() {
    xhost +local:docker               # allow window
    if ! check_docker_instance_already_running; then
        if ! delete_running_docker_instance; then
            return 1
        fi
    fi 
    
    docker run -it \
        --name $instance_name \
        --gpus all \
        --privileged \
        --env NVIDIA_VISIBLE_DEVICES=all \
        --env NVIDIA_DRIVER_CAPABILITIES=all \
        --env DISPLAY=${DISPLAY} \
        --env QT_X11_NO_MITSHM=1 \
        --volume /tmp/.X11-unix:/tmp/.X11-unix \
        --network host \
        $image_name /bin/zsh
}

simulation_main