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
SQL_DOCKER_TAG="app-docker-tag"
SQL_DOCKER_FOLDER="./sqladmin"


sudo apt-get update

sudo apt-get install -y -qq mysql-client

sudo apt-get install -y apache2

sudo pip install --upgrade google-api-python-client

./install-docker.sh

mysql -u root -p $SQL_PASSWORD -h $SQL_IP_ADDRESS <<QUERY_INPUT
CREATE DATABASE $DATABASE_NAME;
CREATE TABLE $DATABASE_NAME.$TABLE_NAME ($COLUMN_PROPERTIES);
QUERY_INPUT

sudo docker build -t $APP_DOCKER_TAG $APP_DOCKER_FOLDER

sudo docker run -p 80:80 -e CLOUDSQL_IP=$SQL_IP_ADDRESS -e CLOUDSQL_PWD=$SQL_PASSWORD $APP_DOCKER_TAG

sudo docker build -t $SQL_DOCKER_TAG $SQL_DOCKER_FOLDER

sudo shutdown -h now

