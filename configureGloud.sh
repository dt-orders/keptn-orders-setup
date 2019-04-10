#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/connectCluster.log)
exec 2>&1

clear
echo "Configuring gcloud connection with values in creds.json"
export CLUSTER_NAME=$(cat creds.json | jq -r '.clusterName')
export CLUSTER_ZONE=$(cat creds.json | jq -r '.clusterZone')
export CLUSTER_REGION=$(cat creds.json | jq -r '.clusterRegion')
export GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')

gcloud --quiet config set project $GKE_PROJECT
gcloud --quiet config set container/cluster $CLUSTER_NAME
gcloud --quiet config set compute/zone $CLUSTER_ZONE
gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE --project $GKE_PROJECT

./showKeptn.sh


