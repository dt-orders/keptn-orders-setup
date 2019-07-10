#!/bin/bash

clear
GKE_CLUSTER_NAME=$(cat creds.json | jq -r '.gkeClusterName')
GKE_CLUSTER_ZONE=$(cat creds.json | jq -r '.gkeClusterZone')
GKE_CLUSTER_REGION=$(cat creds.json | jq -r '.gkeClusterRegion')
GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')

echo "Run these commands on your laptop to configure and run kinbana"
echo ""
echo "gcloud --quiet config set project $GKE_PROJECT"
echo "gcloud --quiet config set container/cluster $GKE_CLUSTER_NAME"
echo "gcloud --quiet config set compute/zone $GKE_CLUSTER_ZONE"
echo "gcloud container clusters get-credentials $GKE_CLUSTER_NAME --zone $GKE_CLUSTER_ZONE --project $GKE_PROJECT"
echo "kubectl proxy"
echo ""
echo ""
echo "Open this Kibana URL in a browser"
echo "http://localhost:8001/api/v1/namespaces/knative-monitoring/services/kibana-logging/proxy/app/kibana#/discover?_g=()"
echo ""
echo "Pick '@timestamp' and the index pattern. In Discover view, use this a search criteria"
echo "keptnEntry: true"



