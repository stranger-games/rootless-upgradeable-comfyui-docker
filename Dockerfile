ARG ROOTLESS_MODE="1"

# This image is based on the latest official PyTorch image, because it already contains CUDA, CuDNN, and PyTorch
FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime AS base

# Installs Git, because ComfyUI and the ComfyUI Manager are installed by cloning their respective Git repositories
RUN apt update --assume-yes && \
    apt install --assume-yes \
        git \
        sudo \
        libgl1-mesa-glx \
        rsync \
        libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# Exposes the default port of ComfyUI (this is not actually exposing the port to the host machine, but it is good practice to include it as metadata,
# so that the user knows which port to publish)
EXPOSE 8188

# Adds the startup script to the container; the startup script will create all necessary directories in the models and custom nodes volumes that were
# mounted to the container and symlink the ComfyUI Manager to the correct directory; it will also create a user with the same UID and GID as the user
# that started the container, so that the files created by the container are owned by the user that started the container and not the root user
COPY entrypoint.sh /entrypoint.sh

COPY create-user-entrypoint.sh /create-user-entrypoint.sh

RUN mkdir /.cache

FROM base AS rootless-1

ARG USER_ID=1234
ARG GROUP_ID=1234

RUN groupadd --gid $GROUP_ID comfyui
RUN useradd --uid $USER_ID --gid $GROUP_ID --create-home comfyui

USER ${USER_ID}:${GROUP_ID}
RUN ls /home
RUN mkdir /home/comfyui/comfyui-tmp
RUN mkdir /home/comfyui/comfyui

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

FROM base AS rootless-0

ENTRYPOINT ["/bin/bash", "/create-user-entrypoint.sh", "/entrypoint.sh"]

FROM rootless-${ROOTLESS_MODE} AS final

WORKDIR /home/comfyui/comfyui
