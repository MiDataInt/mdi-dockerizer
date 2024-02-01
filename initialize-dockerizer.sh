#!/bin/bash

#---------------------------------------------------------------
# Script to set up an AWS Ubuntu instance for building Docker images.
# Create a new EC2 instance, then run this script from an SSH command prompt.
#---------------------------------------------------------------

#---------------------------------------------------------------
# use sudo initially to install resources and configure server as root
#---------------------------------------------------------------

# update system
echo 
echo "updating operating system"
sudo apt-get update
sudo apt-get upgrade -y

# install miscellaneous tools
echo 
echo "install miscellaneous tools"
sudo apt-get install -y \
  git \
  build-essential \
  tree \
  nano \
  dos2unix \
  nfs-common \
  make \
  binutils

# install Docker, now including docker-compose via plugin
echo 
echo "install Docker engine"
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release
sudo mkdir -p /etc/apt/keyrings  
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# allow user ubuntu to control docker without sudo
echo 
echo "add ubuntu to docker group"
sudo usermod -aG docker ubuntu

# set server groups
echo 
echo "create mdi-edit group"
sudo groupadd mdi-edit
sudo usermod -a -G mdi-edit ubuntu

#---------------------------------------------------------------
# continue as user ubuntu (i.e., not sudo) to install the MDI
#---------------------------------------------------------------

# clone the MDI installer
echo 
echo "clone MiDataInt/mdi"
cd ~
git clone https://github.com/MiDataInt/mdi.git

# install the MDI
echo 
echo "install the MDI frameworks"
cd mdi
./install.sh 1 # i.e., pipelines only installation

# validate and report success
echo
echo "installation summary"
echo
docker version
echo
echo ~/mdi
ls -l ~/mdi
echo
