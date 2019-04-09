#!/bin/bash

# load in the shared library and validate argument
. ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/3-provisionInfrastructure.log)
exec 2>&1

clear
case $DEPLOYMENT in
  eks)
    # AWS   
    echo "===================================================="
    echo "About to provision AWS Resources"
    echo ""
    echo Terraform will evalate the plan then prompt for confirmation
    echo at the prompt, enter 'yes'
    echo The provisioning will take several minutes
    read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key
    START_TIME=$(date)

    echo "TODO -- need to add scripts"
    exit 1
    ;;
  aks)
    # Azure 
     AZURE_SUBSCRIPTION=$(cat creds.json | jq -r '.azureSubscription')
     AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')
     AZURE_OWNER_NAME=$(cat creds.json | jq -r '.azureOwnerName')
    echo "===================================================="
    echo "About to provision Azure Resources"
    echo ""
    echo The provisioning will take several minutes
    read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key
     START_TIME=$(date)
    cd ../provisionAks
    ./provisionAksCluster.sh
    ;;
  ocp)
    # Open Shift
    echo "Deploy for $DEPLOYMENT not supported"
    exit 1
    ;;
  gke)
    # Google
     GKE_CLUSTER_NAME=$(cat creds.json | jq -r '.gkeClusterName')
     GKE_CLUSTER_ZONE=$(cat creds.json | jq -r '.gkeClusterZone')
     GKE_CLUSTER_REGION=$(cat creds.json | jq -r '.gkeClusterRegion')
     GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')

    echo "===================================================="
    echo "About to provision Google Resources. The provisioning will take several minutes"
    echo "Google Project              : $GKE_PROJECT"
    echo "Google Cluster Name         : $GKE_CLUSTER_NAME"
    echo "Google Cluster Zone         : $GKE_CLUSTER_ZONE"
    echo "Google Cluster Region       : $GKE_CLUSTER_REGION"
    echo "===================================================="
    echo ""
    read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key
    echo ""
     START_TIME=$(date)
    ./provisionGke.sh $GKE_PROJECT $GKE_CLUSTER_NAME $GKE_CLUSTER_ZONE $GKE_CLUSTER_REGION
    ;;
esac

echo "===================================================="
echo "Finished provisioning $DEPLOYMENT Cluster"
echo "===================================================="
echo "Script start time : $START_TIME"
echo "Script end time   : "$(date)

# validate that have kubectl configured first
./validateKubectl.sh
if [ $? -ne 0 ]
then
  exit 1
fi