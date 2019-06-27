#!/bin/bash

KEPTN_BRANCH=$(cat creds.json | jq -r '.keptnBranch')
KEPTN_GIT_REPO=https://github.com/keptn/installer

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
echo ""
echo "OK, found: $(command -v keptn)"
echo "-------------------------------------------------------"
echo ""

# validate that have dynatrace tokens and URL configure properly
# by testing the connection
./validateDynatrace.sh
if [ $? -ne 0 ]
then
  exit 1
fi

echo "========================================================="
echo "About to install Keptn using branch: $KEPTN_BRANCH"
echo "and to prepare credential files for Keptn installation."
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n=========================================================' -n1 key
echo ""

echo "-------------------------------------------------------"
echo "Creating Dynatrace credential files"
echo -e "Cloning $KEPTN_GIT_REPO branch $KEPTN_BRANCH"
rm -rf installer
git clone --branch $KEPTN_BRANCH https://github.com/keptn/installer --single-branch

cd installer/scripts

echo "-------------------------------------------------------"
echo "Creating Keptn credential files"

# copy the values we already captured 
# and use them to create the creds.json file and the creds_dt.json
# files that the installes expect
SOURCE_CREDS_FILE=../../creds.json
DT_HOSTNAME=$(cat $SOURCE_CREDS_FILE | jq -r '.dynatraceHostName')
DT_URL="https://$DYNATRACE_HOSTNAME"
DT_API_TOKEN=$(cat $SOURCE_CREDS_FILE | jq -r '.dynatraceApiToken')
DT_PAAS_TOKEN=$(cat $SOURCE_CREDS_FILE | jq -r '.dynatracePaaSToken')
GITHUB_PERSONAL_ACCESS_TOKEN=$(cat $SOURCE_CREDS_FILE | jq -r '.githubPersonalAccessToken')
GITHUB_USER_NAME=$(cat $SOURCE_CREDS_FILE | jq -r '.githubUserName')
GITHUB_USER_EMAIL=$(cat $SOURCE_CREDS_FILE | jq -r '.githubUserEmail')
GITHUB_ORGANIZATION=$(cat $SOURCE_CREDS_FILE | jq -r '.githubOrg')
AZURE_SUBSCRIPTION=$(cat $SOURCE_CREDS_FILE | jq -r '.azureSubscription')
AZURE_LOCATION=$(cat $SOURCE_CREDS_FILE | jq -r '.azureLocation')
AZURE_OWNER_NAME=$(cat $SOURCE_CREDS_FILE | jq -r '.azureOwnerName')
GKE_PROJECT=$(cat $SOURCE_CREDS_FILE | jq -r '.gkeProject')
CLUSTER_NAME=$(cat $SOURCE_CREDS_FILE | jq -r '.clusterName')
CLUSTER_ZONE=$(cat $SOURCE_CREDS_FILE | jq -r '.clusterZone')
CLUSTER_REGION=$(cat $SOURCE_CREDS_FILE | jq -r '.clusterRegion')

KEPTN_CREDS_FILE=creds.json
KEPTN_CREDS_SAVE_FILE=creds.sav
rm $KEPTN_CREDS_FILE 2> /dev/null

cat $KEPTN_CREDS_SAVE_FILE | \
  sed 's~CLUSTER_NAME_PLACEHOLDER~'"$CLUSTER_NAME"'~' | \
  sed 's~CLUSTER_ZONE_PLACEHOLDER~'"$CLUSTER_ZONE"'~' | \
  sed 's~CLUSTER_REGION_PLACEHOLDER~'"$CLUSTER_REGION"'~' | \
  sed 's~GKE_PROJECT_PLACEHOLDER~'"$GKE_PROJECT"'~' | \
  sed 's~PERSONAL_ACCESS_TOKEN_PLACEHOLDER~'"$GITHUB_PERSONAL_ACCESS_TOKEN"'~' | \
  sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
  sed 's~GITHUB_USER_NAME_PLACEHOLDER~'"$GITHUB_USER_NAME"'~' | \
  sed 's~GITHUB_ORG_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' >> $KEPTN_CREDS_FILE

KEPTN_DTCREDS_SAVE_FILE=creds_dt.sav
KEPTN_DTCREDS_FILE=creds_dt.json
rm $KEPTN_DTCREDS_FILE 2> /dev/null

cat $KEPTN_DTCREDS_SAVE_FILE | \
  sed 's~DYNATRACE_TENANT_PLACEHOLDER~'"$DT_HOSTNAME"'~' | \
  sed 's~DYNATRACE_API_TOKEN~'"$DT_API_TOKEN"'~' | \
  sed 's~DYNATRACE_PAAS_TOKEN~'"$DT_PAAS_TOKEN"'~' >> $KEPTN_DTCREDS_FILE

echo ""
echo "======================================================="
echo About to install Keptn and Dynatrace with these parameters:
echo ""
echo "cat creds.json"
cat creds.json
echo ""
echo "cat creds_dt.json"
cat creds_dt.json
echo "======================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
echo ""

echo "-------------------------------------------------------"
echo "Running keptn install  This will take several minutes"
echo "-------------------------------------------------------"
START_TIME=$(date)
keptn install -c=creds.json

echo "-------------------------------------------------------"
echo "Finished Running keptn install"
echo "-------------------------------------------------------"
echo "Script start time : $START_TIME"
echo "Script end time   : "$(date)

echo "-------------------------------------------------------"
echo "Running deployDynatrace script.  This will take several minutes"
echo "-------------------------------------------------------"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

START_TIME=$(date)
./deployDynatrace.sh

cd ../..

# adding some sleep for Dyntrace to be ready
sleep 30

echo "-------------------------------------------------------"
echo "Finished Running deployDynatrace script"
echo "-------------------------------------------------------"
echo "Script start time : $START_TIME"
echo "Script end time   : "$(date)

echo "-------------------------------------------------------"
# show Dynatrace
./showDynatrace.sh

# show jenkins
./showJenkins.sh
