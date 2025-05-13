# ComfyUI Docker

This is a rootless, upgradeable Docker image source for [ComfyUI](https://www.comfy.org/), which makes it extremely easy to run ComfyUI on Linux and Windows WSL2. The image also automatically install the [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Managergithub ) extension.

## ROOTLESS_MODE

There are two rootless modes, that you can switch between them. ROOTLESS_MODE 1 will run the container as non-root user, ROOTLESS_MODE 0 (the default) will run the container as root but run comfyui as non-root user.

Mode 1 is more secure but you need to set ownership on the host machine of the mounted folders manually, while mode 0 should automatically do chown for the mounted folders.

!Warning!

In mode 0, if the environment variables USER_ID and GROUP_ID are not set, the container will run comfyui as root.

## Upgradeable

The comfyui repository is cloned in the entrypoint rather than the Dockerfile allowing the user to mount the directory /home/comfyui/comfyui to avoid reinstallation when updating the image. A conda venv environment is also created in /home/comfyui/comfyui/venv.

Even if the user removes the image and re-run it later, if the mounted folder or volume at /home/comfyui/comfyui hasn't changed, no reinstallation is necessary and all python dependencies will not need reinstallation.

## Getting Started

To get started, you have to install [Docker](https://www.docker.com/). This can be either Docker Engine, which can be installed by following the [Docker Engine Installation Manual](https://docs.docker.com/engine/install/) or Docker Desktop, which can be installed by [downloading the installer](https://www.docker.com/products/docker-desktop/) for your operating system.

For easier useage, please make sure to install docker compose.

To enable the usage of NVIDIA GPUs, the NVIDIA Container Toolkit must be installed. The installation process is detailed in the [official documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## Installation

While you can install it using docker CLI I recommend using the composer file. The composer method will be explained below.

First you need to clone this repository.

```shell
git clone https://github.com/stranger-games/rootless-upgradeable-comfyui-docker.git
```
### Docker Compose (Recommended)

Docker Compose is as simple as setting up the environment variables and use the bundled docker-compose.yml file.

#### Environment Variables (REQUIRED)

There are required environment variables that need to be set correctly to build and run the image smoothly.

There is a bundled env example file that you can copy and start from there or you can set the environment variables however you like.

```shell
cp .env.example .env
```


##### Volume Environment Variables
| Folder             | Description                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MODELS_FOLDER             | Where your _model_ files are stored.                                                                                                                                                                                                                                                                                                                                                                            |
| CUSTOM_NODES_FOLDER       | Where your _custom nodes_ are stored.                                                                                                                                                                                                                                                                                                                                                                           |
| OUTPUT_FOLDER             | Where your _output files_ are stored.                                                                                                                                                                                                                                                                                                                                                                           |
| INPUT_FOLDER              | Where any _input files_ are saved by ComfyUI.                                                                                                                                                                                                                                                                                                                                                                   |
| USER_FOLDER           | Where your settings for ComfyUI and ComfyUI Manager are stored, as well as your workflows.                                                                                                                                                                                                                                                                                                                      |
| COMFYUI_FOLDER           | Where the comfyui git repository and venv folder are stored.                                                                                                                                                                                                                                                                                                                                                   |

##### Other Environment Variables

| Env Variable | Description                                                                                                                                                                                           |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PORT     | The port you can access comfyui using.                                                                                                                                               |
| USER_ID         | The _user id_ of your host machine's linux user, if you want the container to attempt to use your user so the files in volumes are owned by your user. You can find this by running `id -u`.          |
| GROUP_ID         | The _group id_ of your host machine's linux user, if you want the container to attempt to use your user so the files in volumes are owned by your user's group. You can find this by running `id -g`. |
| ROOTLESS_MODE         | Check the ROOTLESS_MODE section above. If you set it to 0 (the default) make sure to specify the USER_ID and GROUP_ID above, otherwise comfyui will be run as root |

#### Permissoins

To ensure seamless rootless operation, I recommend creating a non-privileged user on the host machine that owns all the mounted volume folders.

```shell
sudo groupadd comfyui
sudo useradd --gid "$(id -g comfyui)" comfyui

sudo chown --recursive comfyui:comfyui /path/to/mounted/folder1
sudo chown --recursive comfyui:comfyui /path/to/mounted/folder2
```

Then make sure to set the env variables USER_ID and GROUP_ID corresponding to this user. To find out the new user's userid and groupid, use the following command.

```shell
id -u comfyui
id -g comfyui
```

#### Running the Image

After creating your .env file or setting the required environment variables however you please, and making sure you set the permissions correctly, you can run the container using the following command.

```shell
docker compose up
```

## Updating

To update ComfyUI Docker to the latest version you have to first stop the running container, then pull the new version, optionally remove dangling images, and then restart the container:

```shell
git pull
docker compose up --build
```

## License

The ComfyUI Docker image is licensed under the [MIT License](LICENSE). [ComfyUI](https://github.com/comfyanonymous/ComfyUI/blob/master/LICENSE) and the [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Manager/blob/main/LICENSE.txt) are both licensed under the GPL 3.0 license.
