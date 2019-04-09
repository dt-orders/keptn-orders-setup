#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/showDynatrace.log)
exec 2>&1

echo ""
echo "-------------------------------------------------------------------------------"
echo "kubectl -n dynatrace get pods"
echo "-------------------------------------------------------------------------------"
kubectl -n dynatrace get pods
echo "-------------------------------------------------------------------------------"
echo "kubectl get secret dynatrace -n keptn -o yaml"
echo "-------------------------------------------------------------------------------"
kubectl get secret dynatrace -n keptn -o yaml
echo ""

