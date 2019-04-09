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
    export GKE_CLUSTER_NAME=$(cat creds.json | jq -r '.gkeClusterName')
    export GKE_CLUSTER_ZONE=$(cat creds.json | jq -r '.gkeClusterZone')
    export GKE_CLUSTER_REGION=$(cat creds.json | jq -r '.gkeClusterRegion')
    export GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')

    echo "===================================================="
    echo "About to delete $DEPLOYMENT cluster. This will take several minutes"
    echo "Google Project              : $GKE_PROJECT"
    echo "===================================================="
    echo ""
    export START_TIME=$(date)

    # this command will prompt for confirmation
    gcloud container clusters delete $GKE_CLUSTER_NAME --zone=$GKE_CLUSTER_ZONE --project=$GKE_PROJECT 
    ;;
esac

echo "===================================================="
echo "Finished deleting $DEPLOYMENT Cluster"
echo "===================================================="
echo "Script start time : "$START_TIME
echo "Script end time   : "$(date)
