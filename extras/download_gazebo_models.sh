#!/bin/sh

# Download and destionation 
#download_dir=$HOME/Downloads
#dest_dir=$HOME/.gazebo/models

download_dir=$HOME/Downloads
dest_dir=$HOME/Projects/devs/simulation/gazebo/models_online_db

# Download all model archive files
# Models will be downloaded to a folder 'models.gazebosim.org'
# sudo mkdir -p $download_dir
# wget -P $download_dir -l 2 -nc -r "http://models.gazebosim.org/" --accept gz

cd "$download_dir/models.gazebosim.org"

# Extract all model archives
# /bin/sh -c 'for i in *; do `tar -zvxf $i/model.tar.gz`; done'
for i in *
do
  echo "Unzipping contents of $i ..."
  sudo tar -pzvxf "$i/model.tar.gz"
done

# Copy extracted files to the destination models folder
sudo mkdir -p $dest_dir
sudo cp -vfR * $dest_dir
sudo chown -R $USER:$USER $dest_dir

# Remove archive files from destination models folder
cd $dest_dir
sudo find . -name "*.tar.gz" -type f -delete