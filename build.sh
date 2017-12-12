#!/usr/bin/env bash

# Check args
if [ "$#" -ne 1 ]; then
  echo "usage: ./build.sh IMAGE_NAME"
  exit 1
fi

# Set custom arguments
dUSER=docker
dSHELL=/usr/bin/zsh

# Build the docker image
docker build\
  --build-arg user=$dUSER\
  --build-arg uid=$UID\
  --build-arg shell=$dSHELL\
  -t $1 .