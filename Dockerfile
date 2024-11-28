
# This image is based on the latest official PyTorch image, because it already contains CUDA, CuDNN, and PyTorch
FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime

# Installs Git, because ComfyUI and the ComfyUI Manager are installed by cloning their respective Git repositories
RUN apt update --assume-yes && \
    apt install --assume-yes git

# Clones the ComfyUI repository and checks out the latest release
RUN git clone https://github.com/comfyanonymous/ComfyUI.git  /opt/comfyui && \
    cd /opt/comfyui && \
    git checkout tags/v0.3.4

# Sets the working directory to the ComfyUI directory
WORKDIR /opt/comfyui

# Installs the required Python packages
RUN pip install -r requirements.txt

# Installs the ComfyUI Manager, which is an extension for ComfyUI that makes it possible to install, remove, disable, and enable various custom nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager

# Exposes the default port of ComfyUI (this is not actually exposing the port to the host machine, but it is good practice to include it as metadata,
# so that the user knows which port to publish)
EXPOSE 8188

# On startup, ComfyUI is started at its default port; the IP address is changed from localhost to 0.0.0.0, because Docker is only forwarding traffic
# to the IP address it assigns to the container, which is unknown at build time; listening to 0.0.0.0 means that ComfyUI listens to all incoming
# traffic; the auto-launch feature is disabled, because we do not want (nor is it possible) to open a browser window in a Docker container
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188", "--disable-auto-launch"]
