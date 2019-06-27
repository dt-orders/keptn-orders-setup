#!/bin/bash

AZURE_SUBSCRIPTION=$(cat creds.json | jq -r '.azureSubscription')
AZURE_SUBSCRIPTION_ID=$(cat creds.json | jq -r '.azureSubscriptionId')
AZURE_RESOURCE_GROUP=$(cat creds.json | jq -r '.azureResourceGroup')
CLUSTER_NAME=$(cat creds.json | jq -r '.clusterName')
AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')
AKS_VERSION=1.11.9

echo "===================================================="
echo "About to provision Azure Resources"
echo "Azure Subscription   : $AZURE_SUBSCRIPTION"
echo "Azure Resource Group : $AZURE_RESOURCE_GROUP"
echo "Azure Location       : $AZURE_LOCATION"
echo "Cluster Name         : $CLUSTER_NAME"
echo "AKS Version          : $AKS_VERSION"
echo ""
echo The provisioning will take several minutes
echo "===================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

echo "------------------------------------------------------"
echo "Creating Resource group: $AZURE_RESOURCE_GROUP"
echo "------------------------------------------------------"
az account set -s $AZURE_SUBSCRIPTION
az group create --name "$AZURE_RESOURCE_GROUP" --location $AZURE_LOCATION

echo "------------------------------------------------------"
echo "Creating Serice Principal: $AZURE_SERVICE_PRINCIPAL"
echo "------------------------------------------------------"

AZURE_WORKSPACE="$CLUSTER_NAME-workspace"
AZURE_DEPLOYMENTNAME="$CLUSTER_NAME-deployment"
AZURE_SERVICE_PRINCIPAL="http://$CLUSTER_NAME-sp"

az ad sp create-for-rbac -n "$AZURE_SERVICE_PRINCIPAL" \
    --role contributor \
    --scopes /subscriptions/"$AZURE_SUBSCRIPTION_ID"/resourceGroups/"$AZURE_RESOURCE_GROUP" > azure_service_principal.json

AZURE_SERVICE_PRINCIPAL_APPID=$(jq -r .appId azure_service_principal.json)
AZURE_SERVICE_PRINCIPAL_PASSWORD=orders-demo=$(jq -r .password azure_service_principal.json)

echo "Generated Serice Principal App ID: $AZURE_SERVICE_PRINCIPAL_APPID"
echo "Generated Serice Principal Password: $AZURE_SERVICE_PRINCIPAL_PASSWORD"
echo "Letting service principal persist properly (30 sec) ..."
sleep 30 

echo "------------------------------------------------------"
echo "Creating AKS Cluster: $CLUSTER_NAME"
echo "------------------------------------------------------"
az aks create \
    --resource-group $AZURE_RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 1 \
    --generate-ssh-keys \
    --kubernetes-version $AKS_VERSION \
    --service-principal $AZURE_SERVICE_PRINCIPAL_APPID \
    --client-secret $AZURE_SERVICE_PRINCIPAL_PASSWORD \
    --location $AZURE_LOCATION

echo "------------------------------------------------------"
echo "Getting Cluster Credentials"
echo "------------------------------------------------------"
az aks get-credentials --resource-group $AZURE_RESOURCE_GROUP --name $CLUSTER_NAME

echo ""
echo "------------------------------------------------------"
echo "Azure cluster deployment complete."
echo "------------------------------------------------------"
echo ""