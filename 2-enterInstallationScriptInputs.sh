#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/2-enterInstallationScriptInputs.log)
exec 2>&1

CREDS=./creds.json

if [ -f "$CREDS" ]
then
    KEPTN_BRANCH=$(cat creds.json | jq -r '.keptnBranch')\
    DT_TENANT_ID=$(cat creds.json | jq -r '.dynatraceTenant')
    DT_URL=$(cat creds.json | jq -r '.dynatraceUrl')
    DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
    DT_PAAS_TOKEN=$(cat creds.json | jq -r '.dynatracePaaSToken')
    GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')
    GITHUB_USER_NAME=$(cat creds.json | jq -r '.githubUserName')
    GITHUB_USER_EMAIL=$(cat creds.json | jq -r '.githubUserEmail')
    GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
    AZURE_SUBSCRIPTION=$(cat creds.json | jq -r '.azureSubscription')
    AZURE_OWNER_NAME=$(cat creds.json | jq -r '.azureOwnerName')
    GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')
    CLUSTER_NAME=$(cat creds.json | jq -r '.clusterName')
    CLUSTER_ZONE=$(cat creds.json | jq -r '.clusterZone')
    CLUSTER_REGION=$(cat creds.json | jq -r '.clusterRegion')
fi

clear
echo "==================================================================="
echo -e "Please enter the values as requested below:"
echo "==================================================================="
read -p "Dynatrace Tenant ID (8-digits)      (current: $DT_TENANT_ID) : " DT_TENANT_ID_NEW
read -p "Dynatrace Tenant URL                (current: $DT_URL) : " DT_URL_NEW
read -p "Dynatrace API Token                 (current: $DT_API_TOKEN) : " DT_API_TOKEN_NEW
read -p "Dynatrace PaaS Token                (current: $DT_PAAS_TOKEN) : " DT_PAAS_TOKEN_NEW
read -p "GitHub User Name                    (current: $GITHUB_USER_NAME) : " GITHUB_USER_NAME_NEW
read -p "GitHub Personal Access Token        (current: $GITHUB_PERSONAL_ACCESS_TOKEN) : " GITHUB_PERSONAL_ACCESS_TOKEN_NEW
read -p "GitHub User Email                   (current: $GITHUB_USER_EMAIL) : " GITHUB_USER_EMAIL_NEW
read -p "GitHub Organization                 (current: $GITHUB_ORGANIZATION) : " GITHUB_ORGANIZATION_NEW

case $DEPLOYMENT in
  eks)
    read -p "Cluster Name                        (current: $CLUSTER_NAME) : " CLUSTER_NAME_NEW
    read -p "Cluster Region (eg.us-east-1)       (current: $CLUSTER_REGION) : " CLUSTER_REGION_NEW
    ;;
  aks)
    read -p "Azure Subscription                  (current: $AZURE_SUBSCRIPTION) : " AZURE_SUBSCRIPTION_NEW
    read -p "Azure Owner Name                    (current: $AZURE_OWNER_NAME) : " AZURE_OWNER_NAME_NEW
    read -p "Cluster Region (e.g East US)        (current: $CLUSTER_REGION) : " CLUSTER_REGION_NEW
    ;;
  gke)
    read -p "Google Project                      (current: $GKE_PROJECT) : " GKE_PROJECT_NEW
    read -p "Cluster Name                        (current: $CLUSTER_NAME) : " CLUSTER_NAME_NEW
    read -p "Cluster Zone (eg.us-east1-b)        (current: $CLUSTER_ZONE) : " CLUSTER_ZONE_NEW
    read -p "Cluster Region (eg.us-east1)        (current: $CLUSTER_REGION) : " CLUSTER_REGION_NEW
    ;;
  ocp)
    ;;
esac
echo "==================================================================="
echo ""
# set value to new input or default to current value
KEPTN_BRANCH=${KEPTN_BRANCH_NEW:-$KEPTN_BRANCH}
DT_TENANT_ID=${DT_TENANT_ID_NEW:-$DT_TENANT_ID}
DT_URL=${DT_URL_NEW:-$DT_URL}
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
AZURE_LOCATION=${AZURE_LOCATION_NEW:-$AZURE_LOCATION}
AZURE_OWNER_NAME=${AZURE_OWNER_NAME_NEW:-$AZURE_OWNER_NAME}
# gke specific
GKE_PROJECT=${GKE_PROJECT_NEW:-$GKE_PROJECT}
CLUSTER_ZONE=${CLUSTER_ZONE_NEW:-$CLUSTER_ZONE}

echo -e "Please confirm all are correct:"
echo ""
echo "Keptn Branch                : $KEPTN_BRANCH"
echo "Dynatrace Tenant            : $DT_TENANT_ID"
echo "Dynatrace URL               : $DT_URL"
echo "Dynatrace API Token         : $DT_API_TOKEN"
echo "Dynatrace PaaS Token        : $DT_PAAS_TOKEN"
echo "GitHub User Name            : $GITHUB_USER_NAME"
echo "GitHub Personal Access Token: $GITHUB_PERSONAL_ACCESS_TOKEN"
echo "GitHub User Email           : $GITHUB_USER_EMAIL"
echo "GitHub Organization         : $GITHUB_ORGANIZATION" 

case $DEPLOYMENT in
  eks)
    echo "Cluster Name                : $CLUSTER_NAME"
    echo "Cluster Region              : $CLUSTER_REGION"
    ;;
  aks)
    echo "Azure Subscription          : $AZURE_SUBSCRIPTION"
    echo "Azure Owner Name            : $AZURE_OWNER_NAME"
    echo "Cluster Region              : $CLUSTER_REGION"
    ;;
  gke)
    echo "Google Project              : $GKE_PROJECT"
    echo "Cluster Name                : $CLUSTER_NAME"
    echo "Cluster Region              : $CLUSTER_REGION"
    echo "Cluster Zone                : $CLUSTER_ZONE"
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
      sed 's~KEPTN_BRANCH_PLACEHOLDER~'"$KEPTN_BRANCH"'~' | \
      sed 's~DYNATRACE_TENANT_PLACEHOLDER~'"$DT_TENANT_ID"'~' | \
      sed 's~DYNATRACE_URL_PLACEHOLDER~'"$DT_URL"'~' | \
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
          sed 's~AZURE_OWNER_NAME_PLACEHOLDER~'"$AZURE_OWNER_NAME"'~' > $CREDS
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