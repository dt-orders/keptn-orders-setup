#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/showKeptn.log)
exec 2>&1

export BROKER_DOMAIN_URL=$(kubectl get ksvc event-broker-ext -n keptn -o=json | jq -r .status.domain)
export KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -o=yaml | yq - r data.keptn-api-token | base64 --decode)

echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl -n keptn get pods"
echo "--------------------------------------------------------------------------"
kubectl -n keptn get pods
echo "--------------------------------------------------------------------------"
echo "kubectl -n knative-serving get pods"
echo "--------------------------------------------------------------------------"
kubectl -n knative-serving get pods
echo "--------------------------------------------------------------------------"
echo "Keptn Event Broker is running @ "
echo "https://$BROKER_DOMAIN_URL/dynatrace"
echo ""
echo "Keptn API Token:"
echo "Bearer $KEPTN_API_TOKEN"
echo "--------------------------------------------------------------------------"
echo ""

