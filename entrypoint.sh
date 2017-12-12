#! /bin/bash
set -e

# Source ROS setup
source  /opt/ros/kinetic/setup.bash

# Source enviroment variables for Gazebo
source /usr/share/gazebo/setup.sh

# Disable loading of Gazebo models from online model database
# Only local models to be used when mapped accordingly yo $HOME/.gazebo/models
export GAZEBO_MODEL_DATABASE_URI=""
export GAZEBO_MODEL_PATH=$HOME/.gazebo/models

# Reminder of user to source the custom catkin_ws/devel/setup.zhs or setup.bash when building ROS packages
default_shell=$(echo $SHELL)
echo "Default shell is '$default_shell'"

if [[ $default_shell =~ .*zsh.* ]]; then
	export INFO_MSG="[INFO] remember to source custom setup.zsh script from catkin_ws/devel" 
	echo "$INFO_MSG"
	# source catkin_ws/devel/setup.zsh
	# echo "source $HOME/catkin_ws/devel/setup.zsh" >> $HOME/.zshrc

elif [[ $default_shell =~ .*bash.* ]]; then
	export INFO_MSG="[INFO] remember to source custom setup.zsh script from catkin_ws/devel" 
 	echo "$INFO_MSG"
 	# source $HOME/catkin_ws/devel/setup.bash
	# echo "source $HOME/catkin_ws/devel/setup.bash" >> $HOME/.bashrc
fi

exec "$@"
