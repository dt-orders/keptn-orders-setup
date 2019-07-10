#!/bin/bash

export BROKER_DOMAIN_URL=$(kubectl get ksvc event-broker-ext -n keptn -o=json | jq -r .status.domain)
export KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -o=yaml | yq - r data.keptn-api-token | base64 --decode)

echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl -n keptn get pods"
echo "--------------------------------------------------------------------------"
kubectl -n keptn get pods
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl -n keptn get configmaps"
echo "--------------------------------------------------------------------------"
kubectl -n keptn get configmaps
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get svc istio-ingressgateway -n istio-system"
kubectl get svc istio-ingressgateway -n istio-system
echo "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get routes -n keptn"
kubectl get routes -n keptn
echo "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get channels -n keptn"
kubectl get channels -n keptn
echo "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get subscription -n keptn"
echo "--------------------------------------------------------------------------"
kubectl get subscription -n keptn
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get pods -n istio-system"
kubectl get pods -n istio-system
echo "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get pods -n knative-serving"
kubectl get pods -n knative-serving
echo "--------------------------------------------------------------------------"
echo ""
# Retrieve keptn endpoint and api-token
KEPTN_ENDPOINT=https://$(kubectl get ksvc -n keptn control -o=yaml | yq r - status.domain)
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -o=yaml | yq - r data.keptn-api-token | base64 --decode)

echo "keptn endpoint: $KEPTN_ENDPOINT"
echo "keptn api-token: $KEPTN_API_TOKEN"
echo ""
