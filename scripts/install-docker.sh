#! /bin/sh
#
# File: configure.sh
#
# Purpose: To install Docker on a Google Compute Engien Image for use with Guestbook
#
# Pre-conditions:
#  Debian 8 OS
#  This script is run from the Git repo directory
#

echo 'Changing to user home directory'
cd

echo 'Installing Docker...'
sudo apt-get purge lxc-docker*
sudo apt-get purge docker.io*
sudo apt-get update
sudo apt-get -y -qq install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo bash -c "echo deb https://apt.dockerproject.org/repo debian-jessie main >> /etc/apt/sources.list.d/docker.list"
sudo apt-get update
sudo apt-cache policy docker-engine
sudo apt-get -y -qq install docker-engine
sudo service docker start
sudo docker run hello-world
sudo gpasswd -a $USER docker
sudo service docker restart

echo 'Finished with installation script'