#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

clear
START_TIME=$(date)
case $DEPLOYMENT in
  eks)
    ./provisionEks.sh
    ;;
  aks)
    ./provisionAks.sh
    ;;
  ocp)
    echo "Deploy for $DEPLOYMENT not supported"
    exit 1
    ;;
  gke)
    ./provisionGke.sh
    ;;
esac

if [[ $? != 0 ]]; then
  echo ""
  echo "ABORTING due to provisioning error"
  exit 1
fi

# adding some sleep for validateKubectl sometimes fails, if cluster not fully ready
sleep 20

echo "===================================================="
echo "Finished provisioning $DEPLOYMENT_NAME Cluster"
echo "===================================================="
echo "Script start time : $START_TIME"
echo "Script end time   : "$(date)

# validate that have kubectl configured first
./validateKubectl.sh
if [ $? -ne 0 ]
then
  exit 1
fi
