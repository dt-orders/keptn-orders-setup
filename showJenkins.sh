#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/showJenkins.log)
exec 2>&1

INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o=json | jq -r .status.loadBalancer.ingress[].ip)
JENKINS_USER=$(cat creds.json | jq -r '.jenkinsUser')
JENKINS_PASSWORD=$(cat creds.json | jq -r '.jenkinsPassword')
JENKINS_URL="http://jenkins.keptn.$INGRESS_IP.xip.io/"

echo ""
echo "--------------------------------------------------------------------------"
echo "Jenkins is running @"
echo "$JENKINS_URL"
echo "Admin user           : $JENKINS_USER"
echo "Admin password       : $JENKINS_PASSWORD"
echo ""
echo "NOTE: Credentials are from values in creds.json file "
echo "Password may not be accurate if you adjusted it in Jenkins UI"
echo "--------------------------------------------------------------------------"
echo ""