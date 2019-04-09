#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/6-onboardOrderApp.log)
exec 2>&1

clear

KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -o=yaml | yq - r data.keptn-api-token | base64 --decode)
KEPTN_ENDPOINT=https://$(kubectl get ksvc -n keptn control -o=yaml | yq r - status.domain)
GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')
GITHUB_USER_NAME=$(cat creds.json | jq -r '.githubUserName')
GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
KEPTN_PROJECT=orders-project

echo "-----------------------------------------------------"
echo "Configuring keptn CLI with:"
echo "KEPTN endpoint               : $KEPTN_ENDPOINT"
echo "KEPTN API token              : $KEPTN_API_TOKEN"
echo "GitHub User Name             : $GITHUB_USER_NAME"
echo "GitHub Personal Access Token : $GITHUB_PERSONAL_ACCESS_TOKEN"
echo "GitHub Organization          : $GITHUB_ORGANIZATION" 
echo "-----------------------------------------------------"
echo ""
keptn auth --endpoint=$KEPTN_ENDPOINT --api-token=$KEPTN_API_TOKEN
keptn configure --org=$GITHUB_ORGANIZATION --user=$GITHUB_USER_NAME --token=$GITHUB_PERSONAL_ACCESS_TOKEN

echo "-----------------------------------------------------"
echo "Running 'keptn create project $KEPTN_PROJECT ' "
echo "-----------------------------------------------------"
keptn create project $KEPTN_PROJECT ./keptn-onboarding/shipyard.yaml
echo ""
echo "Sleeping 30 sec to allow project to be registered"
sleep 30
echo ""
echo "-----------------------------------------------------"
echo "Running 'keptn onboard service'"
echo "-----------------------------------------------------"
echo "front-end"
keptn onboard service --project=$KEPTN_PROJECT --values=./keptn-onboarding/values_front-end.yaml
echo ""
echo "Sleeping 10 sec to allow for service to be registered"
sleep 10
echo "customer-service"
keptn onboard service --project=$KEPTN_PROJECT --values=./keptn-onboarding/values_customer-service.yaml
echo ""
echo "Sleeping 10 sec to allow for service to be registered"
sleep 10
echo "order-service"
keptn onboard service --project=$KEPTN_PROJECT --values=./keptn-onboarding/values_order-service.yaml
echo ""
echo "Sleeping 10 sec to allow for service to be registered"
sleep 10
echo "catalog-service"
keptn onboard service --project=$KEPTN_PROJECT --values=./keptn-onboarding/values_catalog-service.yaml


echo ""
echo "-----------------------------------------------------"
echo "Complete. View Keptn project files @ "
echo "  http://github.com/$GITHUB_ORGANIZATION/$KEPTN_PROJECT"
echo "-----------------------------------------------------"
