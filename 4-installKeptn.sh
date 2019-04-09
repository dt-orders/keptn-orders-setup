#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/4-installKeptn.log)
exec 2>&1

# TODO: Add argument validation
if [ -z $1 ]
then
  BRANCH="prerelease-0.2.x"
else
  BRANCH=$1
fi

GIT_REPO=https://github.com/keptn/keptn

clear
echo "-------------------------------------------------------"
echo -n "Validating keptn CLI installed. "
type keptn &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing 'keptn' CLI utility"
    echo ""
    exit 1
fi
echo "OK, found: $(command -v keptn)"
echo ""

echo "-------------------------------------------------------"
echo "Removing cloned keptn folder and then re-cloning it"
rm -rf keptn/
echo -e "Cloning $GIT_REPO"
git clone -q "$GIT_REPO"

echo "-------------------------------------------------------"
echo "Checking out branch $BRANCH"
cd keptn
git checkout $BRANCH
cd ..
echo ""

echo "-------------------------------------------------------"
echo "Creating creds.json file"

# copy the values we already captured 
# and use them to create the creds.json file and the creds_dt.json
# files that the keptn.sh expects. This save the need to call
# keptn/install/scripts/defineCredentials.sh and defineDynatraceCredentials.sh 
export DT_TENANT_ID=$(cat creds.json | jq -r '.dynatraceTenant')
export DT_URL=$(cat creds.json | jq -r '.dynatraceUrl')
export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
export DT_PAAS_TOKEN=$(cat creds.json | jq -r '.dynatracePaaSToken')
export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')
export GITHUB_USER_NAME=$(cat creds.json | jq -r '.githubUserName')
export GITHUB_USER_EMAIL=$(cat creds.json | jq -r '.githubUserEmail')
export GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
export AZURE_SUBSCRIPTION=$(cat creds.json | jq -r '.azureSubscription')
export AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')
export AZURE_OWNER_NAME=$(cat creds.json | jq -r '.azureOwnerName')
export GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')
export GKE_CLUSTER_NAME=$(cat creds.json | jq -r '.gkeClusterName')
export GKE_CLUSTER_ZONE=$(cat creds.json | jq -r '.gkeClusterZone')
export GKE_CLUSTER_REGION=$(cat creds.json | jq -r '.gkeClusterRegion')

KEPTN_CREDS_FILE=keptn/install/scripts/creds.json
KEPTN_CREDS_SAVE_FILE=keptn/install/scripts/creds.sav
rm $KEPTN_CREDS_FILE 2> /dev/null
cat $KEPTN_CREDS_SAVE_FILE | sed 's~GITHUB_USER_NAME_PLACEHOLDER~'"$GITHUB_USER_NAME"'~' | \
  sed 's~PERSONAL_ACCESS_TOKEN_PLACEHOLDER~'"$GITHUB_PERSONAL_ACCESS_TOKEN"'~' | \
  sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
  sed 's~CLUSTER_NAME_PLACEHOLDER~'"$GKE_CLUSTER_NAME"'~' | \
  sed 's~CLUSTER_ZONE_PLACEHOLDER~'"$GKE_CLUSTER_ZONE"'~' | \
  sed 's~CLUSTER_REGION_PLACEHOLDER~'"$GKE_CLUSTER_REGION"'~' | \
  sed 's~GKE_PROJECT_PLACEHOLDER~'"$GKE_PROJECT"'~' | \
  sed 's~DYNATRACE_TENANT_PLACEHOLDER~'"$DT_TENANT_ID"'~' | \
  sed 's~DYNATRACE_API_TOKEN~'"$DT_API_TOKEN"'~' | \
  sed 's~DYNATRACE_PAAS_TOKEN~'"$DT_PAAS_TOKEN"'~' | \
  sed 's~GITHUB_ORG_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' >> $KEPTN_CREDS_FILE

KEPTN_DTCREDS_FILE=keptn/install/scripts/creds_dt.json
KEPTN_DTCREDS_SAVE_FILE=keptn/install/scripts/creds_dt.sav
rm $KEPTN_DTCREDS_FILE 2> /dev/null
cat $KEPTN_DTCREDS_SAVE_FILE | sed 's~DYNATRACE_TENANT_PLACEHOLDER~'"$DT_TENANT_ID"'~' | \
      sed 's~DYNATRACE_API_TOKEN~'"$DT_API_TOKEN"'~' | \
      sed 's~DYNATRACE_PAAS_TOKEN~'"$DT_PAAS_TOKEN"'~' >> $KEPTN_DTCREDS_FILE

echo "===================================================="
echo About to install Keptn with these parameters:
echo ""
echo "cat keptn/install/scripts/creds.json"
cat keptn/install/scripts/creds.json
echo ""
echo "cat keptn/install/scripts/creds_dt.json"
cat keptn/install/scripts/creds_dt.json
echo ""
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key
echo ""

echo "-------------------------------------------------------"
echo "Running installKeptn.sh  This will take several minutes"
echo "-------------------------------------------------------"
START_TIME=$(date)
cd keptn/install/scripts
./installKeptn.sh

echo "-------------------------------------------------------"
echo "Finished Running installKeptn.sh"
echo "-------------------------------------------------------"
echo "Script start time : $START_TIME"
echo "Script end time   : "$(date)
../../../showKeptn.sh

echo "-------------------------------------------------------"
echo "Running deployDynatrace.sh  This will take several minutes"
echo "-------------------------------------------------------"
START_TIME=$(date)
./deployDynatrace.sh

echo "-------------------------------------------------------"
echo "Finished Running deployDynatrace.sh"
echo "-------------------------------------------------------"
echo "Script start time : $START_TIME"
echo "Script end time   : "$(date)
../../../showDynatrace.sh

# change back to main setup repo base folder
cd ../../../

# show jenkins
./showJenkins.sh

