#!/bin/bash

# Clones the ComfyUI repository and checks out the latest release
if [[ ! -d "/home/comfyui/comfyui/.git" ]]
then
    if [[ ! -d "/home/comfyui/comfyui-tmp/.git" ]]
    then
        if ! git clone https://github.com/comfyanonymous/ComfyUI.git /home/comfyui/comfyui-tmp
        then
            exit 1
        fi
    fi
    rsync -av --remove-source-files /home/comfyui/comfyui-tmp/ /home/comfyui/comfyui/
    find /home/comfyui/comfyui-tmp/ -depth -type d -empty -delete
    echo "the following ls command should return no files"
    ls -a -R /home/comfyui/comfyui-tmp
fi

# Clones the ComfyUI Manager repository and checks out the latest release; ComfyUI Manager is an extension for ComfyUI that enables users to install
# custom nodes and download models directly from the ComfyUI interface; instead of installing it to "/home/comfyui/comfyui/custom_nodes/ComfyUI-Manager", which
# is the directory it is meant to be installed in, it is installed to its own directory; the entrypoint will symlink the directory to the correct
# location upon startup; the reason for this is that the ComfyUI Manager must be installed in the same directory that it installs custom nodes to, but
# this directory is mounted as a volume, so that the custom nodes are not installed inside of the container and are not lost when the container is
# removed; this way, the custom nodes are installed on the host machine
[ -d "/home/comfyui/comfyui/custom_nodes/comfyui-manager/.git" ] || git clone https://github.com/ltdrdata/ComfyUI-Manager.git /home/comfyui/comfyui/custom_nodes/comfyui-manager

# create and activate a local conda environment. This will be in the mounted folder saving time when updating as the already installed dependencies will be used
PYTHON_VERSION=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')")
[ -d "/home/comfyui/comfyui/venv" ] || (echo "Creating venv" && conda create --prefix /home/comfyui/comfyui/venv python="$PYTHON_VERSION")
PATH=/home/comfyui/comfyui/venv/bin:$PATH

# Installs the required Python packages for both ComfyUI and the ComfyUI Manager
pip install \
    --requirement /home/comfyui/comfyui/requirements.txt \
    --requirement /home/comfyui/comfyui/custom_nodes/comfyui-manager/requirements.txt

# The custom nodes that were installed using the ComfyUI Manager may have requirements of their own, which are not installed when the container is
# started for the first time; this loops over all custom nodes and installs the requirements of each custom node
echo "Installing requirements for custom nodes..."
for CUSTOM_NODE_DIRECTORY in /home/comfyui/comfyui/custom_nodes/*;
do
    if [ "$CUSTOM_NODE_DIRECTORY" != "/home/comfyui/comfyui/custom_nodes/ComfyUI-Manager" ];
    then
        if [ -f "$CUSTOM_NODE_DIRECTORY/requirements.txt" ];
        then
            CUSTOM_NODE_NAME=${CUSTOM_NODE_DIRECTORY##*/}
            CUSTOM_NODE_NAME=${CUSTOM_NODE_NAME//[-_]/ }
            echo "Installing requirements for $CUSTOM_NODE_NAME..."
            pip install --requirement "$CUSTOM_NODE_DIRECTORY/requirements.txt"
        fi
    fi
done

# On startup, ComfyUI is started at its default port; the IP address is changed from localhost to 0.0.0.0, because Docker is only forwarding traffic
# to the IP address it assigns to the container, which is unknown at build time; listening to 0.0.0.0 means that ComfyUI listens to all incoming
# traffic; the auto-launch feature is disabled, because we do not want (nor is it possible) to open a browser window in a Docker container
python main.py --listen 0.0.0.0 --port 8188 --disable-auto-launch \
 --output-directory /home/comfyui/comfyui-ext/output_folder \
 --input-directory /home/comfyui/comfyui-ext/input_folder \
 --user-directory /home/comfyui/comfyui-ext/user_folder
