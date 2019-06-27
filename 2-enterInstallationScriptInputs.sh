#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

CREDS=./creds.json

if [ -f "$CREDS" ]
then
    DEPLOYMENT=$(cat creds.json | jq -r '.deployment | select (.!=null)')
    if [ -n $DEPLOYMENT ]
    then 
      DEPLOYMENT=$1
    fi
    KEPTN_BRANCH=$(cat creds.json | jq -r '.keptnBranch')\
    DT_TENANT_ID=$(cat creds.json | jq -r '.dynatraceTenant')
    DT_HOSTNAME=$(cat creds.json | jq -r '.dynatraceHostName')
    DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
    DT_PAAS_TOKEN=$(cat creds.json | jq -r '.dynatracePaaSToken')
    GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')
    GITHUB_USER_NAME=$(cat creds.json | jq -r '.githubUserName')
    GITHUB_USER_EMAIL=$(cat creds.json | jq -r '.githubUserEmail')
    GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
    CLUSTER_NAME=$(cat creds.json | jq -r '.clusterName')
    CLUSTER_ZONE=$(cat creds.json | jq -r '.clusterZone')
    CLUSTER_REGION=$(cat creds.json | jq -r '.clusterRegion')

    AZURE_SUBSCRIPTION=$(cat creds.json | jq -r '.azureSubscription')
    AZURE_SUBSCRIPTION_ID=$(cat creds.json | jq -r '.azureSubscriptionId')
    AZURE_RESOURCE_GROUP=$(cat creds.json | jq -r '.azureResourceGroup')
    AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')

    GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')
fi

clear
echo "==================================================================="
echo -e "Please enter the values for provider type: $DEPLOYMENT_NAME:"
echo "==================================================================="
echo "Dynatrace Host Name (e.g. abc12345.live.dynatrace.com)"
read -p "                                       (current: $DT_HOSTNAME) : " DT_HOSTNAME_NEW
read -p "Dynatrace API Token                    (current: $DT_API_TOKEN) : " DT_API_TOKEN_NEW
read -p "Dynatrace PaaS Token                   (current: $DT_PAAS_TOKEN) : " DT_PAAS_TOKEN_NEW
read -p "GitHub User Name                       (current: $GITHUB_USER_NAME) : " GITHUB_USER_NAME_NEW
read -p "GitHub Personal Access Token           (current: $GITHUB_PERSONAL_ACCESS_TOKEN) : " GITHUB_PERSONAL_ACCESS_TOKEN_NEW
read -p "GitHub User Email                      (current: $GITHUB_USER_EMAIL) : " GITHUB_USER_EMAIL_NEW
read -p "GitHub Organization                    (current: $GITHUB_ORGANIZATION) : " GITHUB_ORGANIZATION_NEW

case $DEPLOYMENT in
  eks)
    read -p "Cluster Name                           (current: $CLUSTER_NAME) : " CLUSTER_NAME_NEW
    read -p "Cluster Region (eg.us-east-1)          (current: $CLUSTER_REGION) : " CLUSTER_REGION_NEW
    ;;
  aks)
    read -p "Azure Subscription                     (current: $AZURE_SUBSCRIPTION) : " AZURE_SUBSCRIPTION_NEW
    read -p "Azure Subscription ID                  (current: $AZURE_SUBSCRIPTION_ID) : " AZURE_SUBSCRIPTION_ID_NEW
    read -p "Azure Location                         (current: $AZURE_LOCATION) : " AZURE_LOCATION_NEW
    read -p "Azure Resource Group                   (current: $AZURE_RESOURCE_GROUP) : " AZURE_RESOURCE_GROUP_NEW
    ;;
  gke)
    read -p "Google Project                         (current: $GKE_PROJECT) : " GKE_PROJECT_NEW
    read -p "Cluster Name                           (current: $CLUSTER_NAME) : " CLUSTER_NAME_NEW
    read -p "Cluster Zone (eg.us-east1-b)           (current: $CLUSTER_ZONE) : " CLUSTER_ZONE_NEW
    read -p "Cluster Region (eg.us-east1)           (current: $CLUSTER_REGION) : " CLUSTER_REGION_NEW
    ;;
  ocp)
    ;;
esac
echo "==================================================================="
echo ""
# set value to new input or default to current value
KEPTN_BRANCH=${KEPTN_BRANCH_NEW:-$KEPTN_BRANCH}
DT_TENANT_ID=${DT_TENANT_ID_NEW:-$DT_TENANT_ID}
DT_HOSTNAME=${DT_HOSTNAME_NEW:-$DT_HOSTNAME}
DT_API_TOKEN=${DT_API_TOKEN_NEW:-$DT_API_TOKEN}
DT_PAAS_TOKEN=${DT_PAAS_TOKEN_NEW:-$DT_PAAS_TOKEN}
GITHUB_USER_NAME=${GITHUB_USER_NAME_NEW:-$GITHUB_USER_NAME}
GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_PERSONAL_ACCESS_TOKEN_NEW:-$GITHUB_PERSONAL_ACCESS_TOKEN}
GITHUB_USER_EMAIL=${GITHUB_USER_EMAIL_NEW:-$GITHUB_USER_EMAIL}
GITHUB_ORGANIZATION=${GITHUB_ORGANIZATION_NEW:-$GITHUB_ORGANIZATION}
CLUSTER_NAME=${CLUSTER_NAME_NEW:-$CLUSTER_NAME}
CLUSTER_REGION=${CLUSTER_REGION_NEW:-$CLUSTER_REGION}
# aks specific
AZURE_SUBSCRIPTION=${AZURE_SUBSCRIPTION_NEW:-$AZURE_SUBSCRIPTION}
AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID_NEW:-$AZURE_SUBSCRIPTION_ID}
AZURE_LOCATION=${AZURE_LOCATION_NEW:-$AZURE_LOCATION}
AZURE_RESOURCE_GROUP=${AZURE_RESOURCE_GROUP_NEW:-$AZURE_RESOURCE_GROUP}
# gke specific
GKE_PROJECT=${GKE_PROJECT_NEW:-$GKE_PROJECT}
CLUSTER_ZONE=${CLUSTER_ZONE_NEW:-$CLUSTER_ZONE}

echo -e "Please confirm all are correct:"
echo ""
echo "Dynatrace Tenant             : $DT_TENANT_ID"
echo "Dynatrace Host Name          : $DT_HOSTNAME"
echo "Dynatrace API Token          : $DT_API_TOKEN"
echo "Dynatrace PaaS Token         : $DT_PAAS_TOKEN"
echo "GitHub User Name             : $GITHUB_USER_NAME"
echo "GitHub Personal Access Token : $GITHUB_PERSONAL_ACCESS_TOKEN"
echo "GitHub User Email            : $GITHUB_USER_EMAIL"
echo "GitHub Organization          : $GITHUB_ORGANIZATION" 

case $DEPLOYMENT in
  eks)
    echo "Cluster Name                 : $CLUSTER_NAME"
    echo "Cluster Region               : $CLUSTER_REGION"
    ;;
  aks)
    echo "Azure Subscription           : $AZURE_SUBSCRIPTION"
    echo "Azure Subscription ID        : $AZURE_SUBSCRIPTION_ID"
    echo "Azure Resource Group         : $AZURE_RESOURCE_GROUP"
    echo "Azure Location               : $AZURE_LOCATION"
    ;;
  gke)
    echo "Google Project               : $GKE_PROJECT"
    echo "Cluster Name                 : $CLUSTER_NAME"
    echo "Cluster Region               : $CLUSTER_REGION"
    echo "Cluster Zone                 : $CLUSTER_ZONE"
    ;;
  ocp)
    ;;
esac
echo "==================================================================="
read -p "Is this all correct? (y/n) : " -n 1 -r
echo ""
echo "==================================================================="

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Making a backup $CREDS to $CREDS.bak"
    cp $CREDS $CREDS.bak 2> /dev/null
    rm $CREDS 2> /dev/null

    cat ./creds.sav | \
      sed 's~DEPLOYMENT_PLACEHOLDER~'"$DEPLOYMENT"'~' | \
      sed 's~KEPTN_BRANCH_PLACEHOLDER~'"$KEPTN_BRANCH"'~' | \
      sed 's~DYNATRACE_TENANT_PLACEHOLDER~'"$DT_TENANT_ID"'~' | \
      sed 's~DYNATRACE_HOSTNAME_PLACEHOLDER~'"$DT_HOSTNAME"'~' | \
      sed 's~DYNATRACE_API_TOKEN_PLACEHOLDER~'"$DT_API_TOKEN"'~' | \
      sed 's~DYNATRACE_PAAS_TOKEN_PLACEHOLDER~'"$DT_PAAS_TOKEN"'~' | \
      sed 's~GITHUB_USER_NAME_PLACEHOLDER~'"$GITHUB_USER_NAME"'~' | \
      sed 's~PERSONAL_ACCESS_TOKEN_PLACEHOLDER~'"$GITHUB_PERSONAL_ACCESS_TOKEN"'~' | \
      sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
      sed 's~GITHUB_ORG_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' | \
      sed 's~CLUSTER_NAME_PLACEHOLDER~'"$CLUSTER_NAME"'~' | \
      sed 's~CLUSTER_REGION_PLACEHOLDER~'"$CLUSTER_REGION"'~' | \
      sed 's~CLUSTER_ZONE_PLACEHOLDER~'"$CLUSTER_ZONE"'~' > $CREDS

    case $DEPLOYMENT in
      eks)
        ;;
      aks)
        cp $CREDS $CREDS.temp
        cat $CREDS.temp | \
          sed 's~AZURE_SUBSCRIPTION_PLACEHOLDER~'"$AZURE_SUBSCRIPTION"'~' | \
          sed 's~AZURE_SUBSCRIPTION_ID_PLACEHOLDER~'"$AZURE_SUBSCRIPTION_ID"'~' | \
          sed 's~AZURE_LOCATION_PLACEHOLDER~'"$AZURE_LOCATION"'~' | \
          sed 's~AZURE_RESOURCE_GROUP_PLACEHOLDER~'"$AZURE_RESOURCE_GROUP"'~' > $CREDS
        rm $CREDS.temp 2> /dev/null
        ;;
      gke)
        cp $CREDS $CREDS.temp
        cat $CREDS.temp | \
          sed 's~GKE_PROJECT_PLACEHOLDER~'"$GKE_PROJECT"'~' > $CREDS
        rm $CREDS.temp 2> /dev/null
        ;;
      ocp)
        ;;
    esac
    echo ""
    echo "The updated credentials file can be found here: $CREDS"
    echo ""
fi
