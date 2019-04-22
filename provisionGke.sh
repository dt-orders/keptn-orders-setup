#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/provisionGke.log)
exec 2>&1

CLUSTER_NAME=$(cat creds.json | jq -r '.clusterName')
CLUSTER_ZONE=$(cat creds.json | jq -r '.clusterZone')
CLUSTER_REGION=$(cat creds.json | jq -r '.clusterRegion')
GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')

echo "===================================================="
echo "About to provision Google Resources. "
echo "The provisioning will take several minutes"
echo "Google Project       : $GKE_PROJECT"
echo "Cluster Name         : $CLUSTER_NAME"
echo "Cluster Zone         : $CLUSTER_ZONE"
echo "Cluster Region       : $CLUSTER_REGION"
echo "===================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
echo ""

CLUSTER_NAME=$(cat creds.json | jq -r '.clusterName')
CLUSTER_ZONE=$(cat creds.json | jq -r '.clusterZone')
CLUSTER_REGION=$(cat creds.json | jq -r '.clusterRegion')
GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')

gcloud --quiet config set project $GKE_PROJECT
gcloud --quiet config set container/cluster $CLUSTER_NAME
gcloud --quiet config set compute/zone $CLUSTER_ZONE
gcloud container --project $GKE_PROJECT clusters create $CLUSTER_NAME \
            --zone $CLUSTER_ZONE \
            --username "admin" \
            --cluster-version "1.11.8-gke.6" \
            --labels=owner=$CLUSTER_NAME \
            --node-labels=owner=$CLUSTER_NAME \
            --machine-type "n1-standard-8" \
            --image-type "UBUNTU" \
            --disk-type "pd-standard" \
            --disk-size "100" \
            --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
            --num-nodes "1" \
            --enable-cloud-logging \
            --enable-cloud-monitoring \
            --no-enable-ip-alias \
            --addons HorizontalPodAutoscaling,HttpLoadBalancing \
            --no-enable-autoupgrade \
            --no-enable-autorepair

gcloud container clusters get-credentials $CLUSTER_NAME \
            --zone $CLUSTER_ZONE \
            --project $GKE_PROJECT

