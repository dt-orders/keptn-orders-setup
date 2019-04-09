#!/bin/bash

# TODO: Add argument validation

export GKE_PROJECT=$1
export GKE_CLUSTER_NAME=$2
export GKE_CLUSTER_ZONE=$3
export GKE_CLUSTER_REGION=$4

gcloud --quiet config set project $GKE_PROJECT
gcloud --quiet config set container/cluster $GKE_CLUSTER_NAME
gcloud --quiet config set compute/zone $GKE_CLUSTER_ZONE
gcloud container --project $GKE_PROJECT clusters create $GKE_CLUSTER_NAME \
            --zone $GKE_CLUSTER_ZONE \
            --username "admin" \
            --cluster-version "1.11.7-gke.12" \
            --machine-type "n1-standard-8" \
            --image-type "UBUNTU" \
            --disk-type "pd-standard" \
            --disk-size "100" \
            --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
            --num-nodes "1" \
            --enable-cloud-logging \
            --enable-cloud-monitoring \
            --no-enable-ip-alias \
            --addons HorizontalPodAutoscaling,HttpLoadBalancing \
            --no-enable-autoupgrade \
            --no-enable-autorepair

gcloud container clusters get-credentials $GKE_CLUSTER_NAME \
            --zone $GKE_CLUSTER_ZONE \
            --project $GKE_PROJECT

