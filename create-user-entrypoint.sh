#!/bin/bash

# Under normal circumstances, the container would be run as the root user, which is not ideal, because the files that are created by the container in
# the volumes mounted from the host, i.e., custom nodes and models downloaded by the ComfyUI Manager, are owned by the root user; the user can specify
# the user ID and group ID of the host user as environment variables when starting the container; if these environment variables are set, a non-root
# user with the specified user ID and group ID is created, and the container is run as this user
if [ -z "$USER_ID" ] || [ -z "$GROUP_ID" ];
then
    echo "Running container as $USER..."
    exec "$@"
else
    echo "Creating non-root user..."
    getent group $GROUP_ID > /dev/null 2>&1 || groupadd --gid $GROUP_ID comfyui
    id -u $USER_ID > /dev/null 2>&1 || useradd --uid $USER_ID --gid $GROUP_ID --create-home comfyui
    mkdir /home/comfyui/comfyui-tmp
    chown --recursive $USER_ID:$GROUP_ID /home/comfyui
    export PATH=$PATH:/home/comfyui/.local/bin

    echo "Running container as $USER..."
    sudo --set-home --preserve-env=PATH --user \#$USER_ID "$@"
fi
