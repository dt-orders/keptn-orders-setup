#!/bin/bash

LOG_LOCATION=../scripts/logs
exec > >(tee -i $LOG_LOCATION/createAksCluster.log)
exec 2>&1

# TODO: Add argument validation

# passed in inputs
AZURE_SUBSCRIPTION=$1
AZURE_LOCATION=$2
AZURE_OWNER_NAME=$3
# derived values
AZURE_RESOURCEGROUP="$AZURE_OWNER_NAME-dt-kube-demo-group"
AZURE_CLUSTER="$AZURE_OWNER_NAME-dt-kube-cluster"
AZURE_WORKSPACE="$AZURE_OWNER_NAME-dt-kube-workspace"
AZURE_DEPLOYMENTNAME="$AZURE_OWNER_NAME-dt-kube-deployment"
AZURE_SERVICE_PRINCIPAL="$AZURE_OWNER_NAME-dt-kube-sp"

echo "------------------------------------------------------"
echo "Creating Resource group: $AZURE_RESOURCEGROUP"
echo "------------------------------------------------------"
az account set -s $AZURE_SUBSCRIPTION
az group create --name "$AZURE_RESOURCEGROUP" --location $AZURE_LOCATION
az group list -o table

echo "------------------------------------------------------"
echo "Creating Serice Principal: $AZURE_SERVICE_PRINCIPAL"
echo "------------------------------------------------------"
az ad sp create-for-rbac -n "$AZURE_SERVICE_PRINCIPAL" \
    --password "$PASSWORD" \
    --role contributor \
    --scopes /subscriptions/"$AZURE_SUBSCRIPTION"/resourceGroups/"$AZURE_RESOURCEGROUP" > azure_service_principal.json
AZURE_APPID=$(jq -r .appId azure_service_principal.json)

echo "Letting service principal persist properly (30 sec) ..."
sleep 30 
echo "Generated Serice Principal App ID: $AZURE_APPID"

# prepare cluster parameters file values
AZURE_OMS_WORKSPACE_ID="/subscriptions/$AZURE_SUBSCRIPTION/resourceGroups/$AZURE_RESOURCEGROUP/providers/Microsoft.OperationalInsights/workspaces/$AZURE_WORKSPACE"
jq -n \
    --arg cluster "$AZURE_CLUSTER" \
    --arg appid "$AZURE_APPID" \
    --arg location "$AZURE_LOCATION" \
    --arg name "NAME" \
    --arg workspace "$AZURE_WORKSPACE" \
    --arg omsworkspaceid "$AZURE_OMS_WORKSPACE_ID" \
    --arg password "$PASSWORD" \ '{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "servicePrincipalClientId": {
            "value": $appid
        },
        "servicePrincipalClientSecret": {
          "value": $password
        },
        "resourceName": {
            "value": $cluster
        },
        "location": {
            "value": $location
        },
        "dnsPrefix": {
            "value": $cluster
        },
        "kubernetesVersion": {
            "value": "1.11.5"
        },
        "workspaceName": {
            "value": $workspace
        },
        "omsWorkspaceId": {
            "value": $omsworkspaceid
        },
        "workspaceRegion": {
            "value": $location
        },
        "enableHttpApplicationRouting": {
            "value": false
        },
        "networkPlugin": {
            "value": "kubenet"
        },
        "enableRBAC": {
            "value": false
        }
    }
}' > parameters.json

echo "------------------------------------------------------"
echo "Creating Cluster with these parameters."
cat parameters.json
echo "------------------------------------------------------"
echo "Deployment will take several minutes ..."

./deploy.sh -i $AZURE_SUBSCRIPTION -g $AZURE_RESOURCEGROUP -n $AZURE_DEPLOYMENTNAME -l $AZURE_LOCATION

echo "------------------------------------------------------"
echo "Azure cluster deployment complete."
echo "------------------------------------------------------"
echo ""