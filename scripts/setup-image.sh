#! /bin/sh
#
# File: setup-image.sh
#
# Purpose: To create a Compute Engine image and setup the SQL database
#
# Pre-conditions:
#  Debian 8 OS
#  Have entered Compute Engine SSH Shell
#  Have run git clone https://github.com/oclipa/GCloudSetupLoadBalancedWebServer
#  This script is run from the Git repo directory
#

SQL_IP_ADDRESS="get from setup-instances.sh"
SQL_PASSWORD="get from setup-instances.sh"

DATABASE_NAME="database-name"
TABLE_NAME="table-name"
COLUMN_PROPERTIES="id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, entry VARCHAR(500)"
APP_DOCKER_TAG="app-docker-tag"
APP_DOCKER_FOLDER="./webserver"
SQL_DOCKER_TAG="sql-docker-tag"
SQL_DOCKER_FOLDER="./sqladmin"

echo UPDATING...
sudo apt-get update

echo INSTALLING MYSQL CLIENT...
sudo apt-get install -y -qq mysql-client

echo INSTALLING APACHE...
sudo apt-get install -y apache2

echo INSTALLING GOOGLE API CLIENT FOR PYTHON...
sudo pip install --upgrade google-api-python-client

echo INSTALLING DOCKER...
./install-docker.sh

echo CREATING SQL DATABASE...
mysql -u root -p $SQL_PASSWORD -h $SQL_IP_ADDRESS -e "CREATE DATABASE $DATABASE_NAME;"

echo CREATING TABLE IN DATABASE...
mysql -u root -p $SQL_PASSWORD -h $SQL_IP_ADDRESS -e "CREATE TABLE $DATABASE_NAME.$TABLE_NAME ($COLUMN_PROPERTIES);"

echo BUILDING DOCKER IMAGE FOR WEB SERVER...
sudo docker build -t $APP_DOCKER_TAG $APP_DOCKER_FOLDER

#sudo docker run -p 80:80 -e CLOUDSQL_IP=$SQL_IP_ADDRESS -e CLOUDSQL_PWD=$SQL_PASSWORD $APP_DOCKER_TAG

echo BUILDING DOCKER IMAGE FOR SQL CLIENT...
sudo docker build -t $SQL_DOCKER_TAG $SQL_DOCKER_FOLDER

echo SHUTTING DOWN INSTANCE...
sudo shutdown -h now

