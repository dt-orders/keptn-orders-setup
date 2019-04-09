#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/showApp.log)
exec 2>&1

export DEV_IP=$(kubectl -n dev get svc front-end -o json | jq -r '.status.loadBalancer.ingress[0].ip')
export INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o=json | jq -r .status.loadBalancer.ingress[].ip)

echo ""
echo "--------------------------------------------------------------------------"
echo "Orders Application:"
echo "--------------------------------------------------------------------------"
echo "Dev running        @ http://front-end.dev.$DEV_IP.xip.io/"
echo "Staging running    @ http://front-end.staging.$INGRESS_IP.xip.io/"
echo "Production running @ http://front-end.production.$INGRESS_IP.xip.io/"
cho "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "Kubernetes dev pods"
kubectl get pods -n dev
echo ""
echo "--------------------------------------------------------------------------"
echo "Kubernetes staging pods"
kubectl get pods -n staging
echo "--------------------------------------------------------------------------"
echo "Kubernetes production pods"
kubectl get pods -n production