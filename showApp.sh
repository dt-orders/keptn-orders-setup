#!/bin/bash

export INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o=json | jq -r .status.loadBalancer.ingress[].ip)

echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl -n orders-project-dev get svc"
kubectl -n orders-project-dev get svc
echo "--------------------------------------------------------------------------"
echo "Orders Application:"
echo "--------------------------------------------------------------------------"
echo "Dev running        @ http://front-end.orders-project-dev.$INGRESS_IP.xip.io/"
echo "Staging running    @ http://front-end.orders-project-staging.$INGRESS_IP.xip.io/"
echo "Production running @ http://front-end.orders-project-production.$INGRESS_IP.xip.io/"
echo "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get pods -n orders-project-dev"
kubectl get pods -n orders-project-dev
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get pods -n orders-project-staging"
kubectl get pods -n orders-project-staging
echo "--------------------------------------------------------------------------"
echo "kubectl get pods -n orders-project-production"
kubectl get pods -n orders-project-production
