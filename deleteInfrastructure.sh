#!/bin/bash

# load in the shared library and validate argument
. ./deploymentArgument.lib
export DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/deleteInfrastructure.log)
exec 2>&1

clear 
case $DEPLOYMENT in
  eks)
    # AWS   
    echo "TODO -- need to add scripts"
    exit 1
    ;;
  aks)
    # Azure
    echo "TODO -- need to add scripts"
    exit 1
    ;;
  ocp)
    # Open shift
    echo "TODO -- need to add scripts"
    exit 1
    ;;
  gke)
    # Google
    export CLUSTER_NAME=$(cat creds.json | jq -r '.clusterName')
    export CLUSTER_ZONE=$(cat creds.json | jq -r '.clusterZone')
    export CLUSTER_REGION=$(cat creds.json | jq -r '.clusterRegion')
    export GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')

    echo "===================================================="
    echo "About to delete $DEPLOYMENT cluster."
    echo "This will take several minutes"
    echo ""
    echo "Google Project : $GKE_PROJECT"
    echo "Cluster Name   : $CLUSTER_NAME"
    echo "Cluster Zone   : $CLUSTER_ZONE"
    echo "===================================================="
    echo ""
    export START_TIME=$(date)
    # this command will prompt for confirmation
    gcloud container clusters delete $CLUSTER_NAME --zone=$CLUSTER_ZONE --project=$GKE_PROJECT 
    ;;
esac

echo "===================================================="
echo "Finished deleting $DEPLOYMENT Cluster"
echo "===================================================="
echo "Script start time : "$START_TIME
echo "Script end time   : "$(date)
