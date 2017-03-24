#! /bin/sh
#
# File: setup-load-balancing.sh
#
# Purpose: To create a Compute Engine from an image and setup load balancing for the Compute Engine
#
# Pre-conditions:
#  Debian 8 OS
#  Have entered Cloud Console
#  Have run git clone https://github.com/oclipa/GCloudSetupLoadBalancedWebServer
#  This script is run from the Git repo directory
#

COMPUTE_ENGINE_INSTANCE_NAME="get from setup-instances.sh"
PRIMARY_ZONE="get from setup-instances.sh"
SQL_INSTANCE_NAME="get from setup-instances.sh"
FIREWALL_RULE_TAG="get from setup-instances.sh"
BUCKET_NAME="get from setup-instances.sh"
SQL_INSTANCE_NAME="get from setup-instances.sh"
SQL_IP_ADDRESS="get from setup-instances.sh"
SQL_PASSWORD="get from setup-instances.sh"

IMAGE_NAME="image-name"
INSTANCE_TEMPLATE_NAME="instance-template-name"
PRIMARY_INSTANCE_GROUP_NAME="primary-instance-group-name"
SECONDARY_INSTANCE_GROUP_NAME="primary-instance-group-name"
BASE_NAME="base-name"
SECONDARY_ZONE="secondary-zone, e.g. europe-west1-d"
MAX_INSTANCES="3"
MIN_INSTANCES="1"
LOAD_BALANCING_UTILIZATION="0.6"
COOL_DOWN_PERIOD="120"
HEALTH_CHECK_NAME="health-check-name"
BACKEND_SERVICE_NAME="backend-service-name"
MAX_REQUEST_RATE="100"
URL_MAP_NAME="url-map-name"
TARGET_PROXY_NAME="target-proxy-name"
FORWARDING_RULE_NAME="forwarding-rule-name"
STARTUP_SCRIPT_PATH="gs://$BUCKET_NAME/startup.sh"

gcloud compute instances delete $COMPUTE_ENGINE_INSTANCE_NAME --keep-disks boot --zone $PRIMARY_ZONE

gcloud compute images create $IMAGE_NAME --source-disk $COMPUTE_ENGINE_INSTANCE_NAME --source-disk-zone $PRIMARY_ZONE

gcloud sql instances patch $SQL_INSTANCE_NAME --clear-authorized-networks

gcloud compute instance-templates create $INSTANCE_TEMPLATE_NAME --image $IMAGE_NAME --tags $FIREWALL_RULE_TAG --scopes=sql-admin,storage-ro,logging-write --metadata startup-script-url=$STARTUP_SCRIPT_PATH,sql-name=$SQL_INSTANCE_NAME,sql-ip=$SQL_IP_ADDRESS,sql-pw=$SQL_PASSWORD

gcloud compute instance-groups managed create $PRIMARY_INSTANCE_GROUP_NAME --base-instance-name $BASE_NAME --size 1 --template $INSTANCE_TEMPLATE_NAME --zone $PRIMARY_ZONE

gcloud compute instance-groups managed set-named-ports $PRIMARY_INSTANCE_GROUP_NAME --named-ports http:80 --zone $PRIMARY_ZONE

gcloud compute instance-groups managed create $SECONDARY_INSTANCE_GROUP_NAME --base-instance-name $BASE_NAME --size 1 --template $INSTANCE_TEMPLATE_NAME --zone $SECONDARY_ZONE

gcloud compute instance-groups managed set-named-ports $SECONDARY_INSTANCE_GROUP_NAME --named-ports http:80 --zone $SECONDARY_ZONE

gcloud compute instance-groups managed set-autoscaling $PRIMARY_INSTANCE_GROUP_NAME --max-num-replicas $MAX_INSTANCES --min-num-replicas $MIN_INSTANCES --target-load-balancing-utilization $LOAD_BALANCING_UTILIZATION --cool-down-period $COOL_DOWN_PERIOD --zone $PRIMARY_ZONE

gcloud compute instance-groups managed set-autoscaling $SECONDARY_INSTANCE_GROUP_NAME --max-num-replicas $MAX_INSTANCES --min-num-replicas $MIN_INSTANCES --target-load-balancing-utilization $LOAD_BALANCING_UTILIZATION --cool-down-period $COOL_DOWN_PERIOD --zone $SECONDARY_ZONE

gcloud compute http-health-checks create $HEALTH_CHECK_NAME

gcloud compute backend-services create $BACKEND_SERVICE_NAME --http-health-checks $HEALTH_CHECK_NAME --global

gcloud compute backend-services add-backend $BACKEND_SERVICE_NAME --instance-group $PRIMARY_INSTANCE_GROUP_NAME --balancing-mode RATE --max-rate-per-instance $MAX_REQUEST_RATE --instance-group-zone $PRIMARY_ZONE --global

gcloud compute backend-services add-backend $BACKEND_SERVICE_NAME --instance-group $SECONDARY_INSTANCE_GROUP_NAME --balancing-mode RATE --max-rate-per-instance $MAX_REQUEST_RATE --instance-group-zone $SECONDARY_ZONE --global

gcloud compute url-maps create $URL_MAP_NAME --default-service $BACKEND_SERVICE_NAME

gcloud compute target-http-proxies create $TARGET_PROXY_NAME --url-map $URL_MAP_NAME

gcloud compute forwarding-rules create $FORWARDING_RULE_NAME --global --ports 80 --target-http-proxy $TARGET_PROXY_NAME

sleep 120

gcloud compute backend-services get-health $BACKEND_SERVICE_NAME --global


#Enable following lines to perform benchmark test

#LB_IP_ADDRESS=$(gcloud compute forwarding-rules describe $FORWARDING_RULE_NAME --global | grep IPAddress | awk '{print $2}')

#sudo apt-get install -y -qq apache2-utils

#ab -n 5000 http://$LB_IP_ADDRESS/


