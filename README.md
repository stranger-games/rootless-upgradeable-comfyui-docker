# ComfyUI Docker

This is a Docker image for [ComfyUI](https://www.comfy.org/), which makes it extremely easy to run ComfyUI on Linux and Windows WSL2. The image also includes the [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Managergithub ) extension.

## Getting Started

To get started, you have to install [Docker](https://www.docker.com/). This can be either Docker Engine, which can be installed by following the [Docker Engine Installation Manual](https://docs.docker.com/engine/install/) or Docker Desktop, which can be installed by [downloading the installer](https://www.docker.com/products/docker-desktop/) for your operating system.

To enable the usage of NVIDIA GPUs, the NVIDIA Container Toolkit must be installed. The installation process is detailed in the [official documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## Building

The image can be build using the following command:

```sh
docker build --tag lecode/comfyui-docker:latest .
```

## Running

The built image can be run like so:

```sh
docker run \
    --name comfyui \
    --detach \
    --restart unless-stopped \
    --volume <path/to/models/folder>:/opt/comfyui/models \
    --publish 8188:8188 \
    --runtime=nvidia \
    --gpus all \
    lecode/comfyui-docker:latest
```

Please note, that the `<path/to/models/folder>` must be replaced with a path to a folder on the host system where the models will be stored, e.g., `$HOME/.comfyui`.

## License

The ComfyUI Docker image is licensed under the [MIT License](LICENSE). [ComfyUI](https://github.com/comfyanonymous/ComfyUI/blob/master/LICENSE) and the [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Manager/blob/main/LICENSE.txt) are both licensed under the GPL 3.0 license.
