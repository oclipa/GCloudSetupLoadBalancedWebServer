#! /bin/sh
#
# File: setup-instances.sh
#
# Purpose: To setup SQL and Compute Engine instances for use with a simple web server
#
# Pre-conditions:
#  Debian 8 OS
#  Have entered Cloud Console
#  Have run git clone https://github.com/oclipa/GCloudSetupLoadBalancedWebServer
#  This script is run from the Git repo directory
#

ADDRESS_NAME="address-name"
PRIMARY_REGION="primary-region, e.g. europe-west1"
PRIMARY_ZONE="primary-zone, e.g. europe-west1-c"
FIREWALL_RULE_TAG="firewall-rule-tag"
BUCKET_NAME="bucket-name"
SQL_FIRST_GEN_MACHINE_TYPE="sql-machine-type"
SQL_INSTANCE_NAME="sql-instance-name"
COMPUTE_ENGINE_INSTANCE_NAME="compute-engine-instance-name"
SQL_PASSWORD="sql-password"
SQL_BACKUP_START_TIME="23:30"

echo CREATING STATIC ADDRESS...
gcloud compute addresses create $ADDRESS_NAME --region $PRIMARY_REGION

echo GETTING STATIC IP ADDRESS...
INSTANCE_IP_ADDRESS=$(gcloud compute addresses describe $ADDRESS_NAME --region $PRIMARY_REGION --format text | head -1 | awk '{print $2}')
echo $INSTANCE_IP_ADDRESS

echo CREATING FIREWALL RULE...
gcloud compute firewall-rules create default-allow-http --allow tcp:80 --target-tags $FIREWALL_RULE_TAG

echo CREATING BUCKET...
gsutil mb -c DRA -l $PRIMARY_REGION gs://$BUCKET_NAME

echo COPYING STARTUP SCRIPT TO BUCKET...
gsutil cp ./startup.sh gs://$BUCKET_NAME/

echo COPYING SHUTDOWN SCRIPT TO BUCKET...
gsutil cp ./shutdown.sh gs://$BUCKET_NAME/

echo CREATING SQL INSTANCE...
gcloud sql instances create $SQL_INSTANCE_NAME --assign-ip --tier $SQL_FIRST_GEN_MACHINE_TYPE --region $PRIMARY_REGION --gce-zone $PRIMARY_ZONE

echo SETTING ROOT PASSWORD FOR SQL INSTANCE...
gcloud sql instances set-root-password $SQL_INSTANCE_NAME  --password $SQL_PASSWORD

echo SETTING BACKUP TIME FOR SQL INSTANCE...
gcloud sql instances patch $SQL_INSTANCE_NAME  --backup-start-time $SQL_BACKUP_START_TIME

echo GETTING IP ADDRESS FOR SQL INSTANCE...
SQL_IP_ADDRESS=$(gcloud sql instances describe $SQL_INSTANCE_NAME --format text | grep ipAddress | awk '{print $2}')
echo $SQL_IP_ADDRESS

echo AUTHORIZING ACCESS TO SQL INSTANCE FROM STATIC IP ADDRESS...
gcloud sql instances patch $SQL_INSTANCE_NAME --authorized-networks $INSTANCE_IP_ADDRESS

echo CREATING COMPUTE ENGINE INSTANCE AT STATIC IP ADDRESS...
gcloud compute instances create $COMPUTE_ENGINE_INSTANCE_NAME --zone $PRIMARY_ZONE --tags $FIREWALL_RULE_TAG --address $INSTANCE_IP_ADDRESS

