#!/bin/bash

# load in the shared library and validate argument
. ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

clear 
case $DEPLOYMENT in
  eks)
    CLUSTER_NAME=$(cat creds.json | jq -r '.clusterName')
    CLUSTER_REGION=$(cat creds.json | jq -r '.clusterRegion')

    echo "===================================================="
    echo "About to delete $DEPLOYMENT cluster."
    echo "  Cluster Name   : $CLUSTER_NAME"
    echo "  Cluster Region : $CLUSTER_REGION"
    echo ""
    echo "This will take several minutes"
    echo "===================================================="
    echo ""
    START_TIME=$(date)
    eksctl delete cluster --name=$CLUSTER_NAME --region=$CLUSTER_REGION
    ;;
  aks)
    CLUSTER_NAME=$(cat creds.json | jq -r '.clusterName')
    AZURE_RESOURCE_GROUP=$(cat creds.json | jq -r '.azureResourceGroup')

    echo "===================================================="
    echo "About to delete:"
    echo "  $DEPLOYMENT cluster        : $CLUSTER_NAME"
    echo "  $DEPLOYMENT resource group : $AZURE_RESOURCE_GROUP"
    echo ""
    echo "This will take several minutes"
    echo "===================================================="
    echo ""
    START_TIME=$(date)
    AZURE_SERVICE_PRINCIPAL="$CLUSTER_NAME-sp"

    echo "Deleting cluster $CLUSTER_NAME ..."
    az aks delete --name $CLUSTER_NAME --resource-group $AZURE_RESOURCE_GROUP
    echo "Deleting resource group $AZURE_RESOURCE_GROUP ..."
    az group delete --name $AZURE_RESOURCE_GROUP -y
    # need to look up service principal id and then delete it
    # this is outside of the resource group
    AZURE_SERVICE_PRINCIPAL_APPID=$(az ad sp list --display-name $AZURE_SERVICE_PRINCIPAL | jq -r '.[0].appId')
    echo "Deleting service principal $AZURE_SERVICE_PRINCIPAL_APPID ..."
    az ad sp delete --id $AZURE_SERVICE_PRINCIPAL_APPID
    ;;
  ocp)
    # Open shift
    echo "TODO -- need to add scripts"
    exit 1
    ;;
  gke)
    CLUSTER_NAME=$(cat creds.json | jq -r '.clusterName')
    CLUSTER_ZONE=$(cat creds.json | jq -r '.clusterZone')
    CLUSTER_REGION=$(cat creds.json | jq -r '.clusterRegion')
    GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')

    echo "===================================================="
    echo "About to delete $DEPLOYMENT cluster."
    echo "  Project        : $GKE_PROJECT"
    echo "  Cluster Name   : $CLUSTER_NAME"
    echo "  Cluster Zone   : $CLUSTER_ZONE"
    echo ""
    echo "This will take several minutes"    
    echo "===================================================="
    echo ""
    START_TIME=$(date)
    # this command will prompt for confirmation
    gcloud container clusters delete $CLUSTER_NAME --zone=$CLUSTER_ZONE --project=$GKE_PROJECT 
    ;;
esac

echo "===================================================="
echo "Finished deleting $DEPLOYMENT Cluster"
echo "===================================================="
echo "Script start time : "$START_TIME
echo "Script end time   : "$(date)
