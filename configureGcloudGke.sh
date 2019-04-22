#!/bin/bash

clear
CLUSTER_NAME=$(cat creds.json | jq -r '.clusterName')
CLUSTER_ZONE=$(cat creds.json | jq -r '.clusterZone')
CLUSTER_REGION=$(cat creds.json | jq -r '.clusterRegion')
GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')

echo "Run these commands on your laptop to configure and run kinbana"
echo ""
echo "gcloud --quiet config set project $GKE_PROJECT"
echo "gcloud --quiet config set container/cluster $CLUSTER_NAME"
echo "gcloud --quiet config set compute/zone $CLUSTER_ZONE"
echo "gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE --project $GKE_PROJECT"
echo ""
echo "Would you like me to run them now?"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

gcloud --quiet config set project $GKE_PROJECT
gcloud --quiet config set container/cluster $CLUSTER_NAME
gcloud --quiet config set compute/zone $CLUSTER_ZONE
gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE --project $GKE_PROJECT

./showKeptn.sh


