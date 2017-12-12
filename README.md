## Docker ROS Kinetic & Gazebo8

Use the [Dockerfile](./Dockerfile) and the [build](./build.sh) & [run](./build.sh) scripts to create and run a customized (user, shell, terminal) Docker container consisting of [ROS Kinetic](http://wiki.ros.org/kinetic) (full version) for Ubuntu Xenial with NVIDIA hardware acceleration, OpenGL support and shared X11 socket. 

The resulting Docker image combines the build steps of the following two images
* [docker_ros_kinetic_gazebo8](https://github.com/gandrein/docker_ros_kinetic_cuda9)
* [docker_customizing_users](https://github.com/gandrein/docker_customizing_users)

Please refer to those repositories for more details about the respective images, customizations and the build process.

### Downloading models locally
Whenever Gazebo is launched in a new container, it will try to connect and download model information from the online database. 

To avoid this, the models can be downloaded once on the local host and then the respective directory mounted in the Docker container at runtime. 

The [download_gazebo_models.sh](./extras/download_gazebo_models.sh) in the [extras](./extras) folder can be used to download the online models locally. 

Subsequently, by adding the following line in the Docker run command
```
    -v $HOME/gazebo/models_online_db:/home/docker/.gazebo/models \
```
and combining it with setting this two lines in the [entrypoint.sh](./entrypoint.sh)
```
export GAZEBO_MODEL_DATABASE_URI=""
export GAZEBO_MODEL_PATH=$HOME/.gazebo/models
```
will make Gazebo start faster and use the locally stored models.

The above settings are already implemented in the [run.sh](./run.sh) and [entrypoint.sh](./entrypoint.sh) scripts of this repository.

