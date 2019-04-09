#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/2-defineWorkshopInputs.log)
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
    AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')
    AZURE_OWNER_NAME=$(cat creds.json | jq -r '.azureOwnerName')
    GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')
    GKE_CLUSTER_NAME=$(cat creds.json | jq -r '.gkeClusterName')
    GKE_CLUSTER_ZONE=$(cat creds.json | jq -r '.gkeClusterZone')
    GKE_CLUSTER_REGION=$(cat creds.json | jq -r '.gkeClusterRegion')
fi

clear
echo "==================================================================="
echo -e "Please enter the values as requested below:"
echo "==================================================================="
read -p "Keptn Branch                        (current: $KEPTN_BRANCH) : " KEPTN_BRANCH_NEW
read -p "Dynatrace Tenant ID (8-digits)      (current: $DT_TENANT_ID) : " DT_TENANT_ID_NEW
read -p "Dynatrace Tenant URL                (current: $DT_URL) : " DT_URL_NEW
read -p "Dynatrace API Token                 (current: $DT_API_TOKEN) : " DT_API_TOKEN_NEW
read -p "Dynatrace PaaS Token                (current: $DT_PAAS_TOKEN) : " DT_PAAS_TOKEN_NEW
read -p "GitHub User Name                    (current: $GITHUB_USER_NAME) : " GITHUB_USER_NAME_NEW
read -p "GitHub Personal Access Token        (current: $GITHUB_PERSONAL_ACCESS_TOKEN) : " GITHUB_PERSONAL_ACCESS_TOKEN_NEW
read -p "GitHub User Email                   (current: $GITHUB_USER_EMAIL) : " GITHUB_USER_EMAIL_NEW
read -p "GitHub Organization                 (current: $GITHUB_ORGANIZATION) : " GITHUB_ORGANIZATION_NEW

case $DEPLOYMENT in
  aks)
    read -p "Azure Subscription                  (current: $AZURE_SUBSCRIPTION) : " AZURE_SUBSCRIPTION_NEW
    read -p "Azure Location                      (current: $AZURE_LOCATION) : " AZURE_LOCATION_NEW
    read -p "Azure Owner Name                    (current: $AZURE_OWNER_NAME) : " AZURE_OWNER_NAME_NEW
    ;;
  gke)
    read -p "Google Project                      (current: $GKE_PROJECT) : " GKE_PROJECT_NEW
    read -p "Google Cluster Name                 (current: $GKE_CLUSTER_NAME) : " GKE_CLUSTER_NAME_NEW
    read -p "Google Cluster Zone (eg.us-east1-b) (current: $GKE_CLUSTER_ZONE) : " GKE_CLUSTER_ZONE_NEW
    read -p "Google Cluster Region (eg.us-east1) (current: $GKE_CLUSTER_REGION) : " GKE_CLUSTER_REGION_NEW
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
# aks specific
AZURE_SUBSCRIPTION=${AZURE_SUBSCRIPTION_NEW:-$AZURE_SUBSCRIPTION}
AZURE_LOCATION=${AZURE_LOCATION_NEW:-$AZURE_LOCATION}
AZURE_OWNER_NAME=${AZURE_OWNER_NAME_NEW:-$AZURE_OWNER_NAME}
# gke specific
GKE_PROJECT=${GKE_PROJECT_NEW:-$GKE_PROJECT}
GKE_CLUSTER_NAME=${GKE_CLUSTER_NAME_NEW:-$GKE_CLUSTER_NAME}
GKE_CLUSTER_ZONE=${GKE_CLUSTER_ZONE_NEW:-$GKE_CLUSTER_ZONE}
GKE_CLUSTER_REGION=${GKE_CLUSTER_REGION_NEW:-$GKE_CLUSTER_REGION}

echo -e "${YLW}Please confirm all are correct: ${NC}"
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
  aks)
    echo "Azure Subscription          : $AZURE_SUBSCRIPTION"
    echo "Azure Location              : $AZURE_LOCATION"
    echo "Azure Owner Name            : $AZURE_OWNER_NAME"
    ;;
  gke)
    echo "Google Project              : $GKE_PROJECT"
    echo "Google Cluster Name         : $GKE_CLUSTER_NAME"
    echo "Google Cluster Zone         : $GKE_CLUSTER_ZONE"
    echo "Google Cluster Region       : $GKE_CLUSTER_REGION"
    ;;
esac
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
      sed 's~GITHUB_ORG_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' >> $CREDS

    case $DEPLOYMENT in
      aks)
        cp $CREDS $CREDS.temp
        cat $CREDS.temp | \
          sed 's~AZURE_SUBSCRIPTION_PLACEHOLDER~'"$AZURE_SUBSCRIPTION"'~' | \
          sed 's~AZURE_LOCATION_PLACEHOLDER~'"$AZURE_LOCATION"'~' | \
          sed 's~AZURE_OWNER_NAME_PLACEHOLDER~'"$AZURE_OWNER_NAME"'~' > $CREDS
        rm $CREDS.temp 2> /dev/null
        ;;
      gke)
        cp $CREDS $CREDS.temp
        cat $CREDS.temp | \
          sed 's~GKE_PROJECT_PLACEHOLDER~'"$GKE_PROJECT"'~' | \
          sed 's~GKE_CLUSTER_NAME_PLACEHOLDER~'"$GKE_CLUSTER_NAME"'~' | \
          sed 's~GKE_CLUSTER_ZONE_PLACEHOLDER~'"$GKE_CLUSTER_ZONE"'~' | \
          sed 's~GKE_CLUSTER_REGION_PLACEHOLDER~'"$GKE_CLUSTER_REGION"'~' > $CREDS
        rm $CREDS.temp 2> /dev/null
        ;;
    esac
    echo ""
    echo "The updated credentials file can be found here:" $CREDS
    echo ""
fi