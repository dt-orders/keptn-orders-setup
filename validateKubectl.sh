#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/validateKubectl.log)
exec 2>&1

echo "----------------------------------------------------"
echo Validating Kubectl configured to cluster
echo "----------------------------------------------------"
export KUBECTL_CONFIG=$(kubectl -n kube-system get pods | grep Running | wc -l | tr -d '[:space:]')
if [ $KUBECTL_CONFIG -eq 0 ]
then
    echo ">>> Unable Connect to Cluster using kubectl.  Verify have configured ~/.kube/config file.  Verify cluster nodes are available."
    echo ""
    exit 1
fi
echo "Able to Connect to Cluster using kubectl."