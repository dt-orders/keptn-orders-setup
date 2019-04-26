#!/bin/bash

export INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o=json | jq -r .status.loadBalancer.ingress[].ip)

echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl -n dev get svc"
kubectl -n dev get svc
echo "--------------------------------------------------------------------------"
echo "Orders Application:"
echo "--------------------------------------------------------------------------"
echo "Dev running        @ http://front-end.dev.$INGRESS_IP.xip.io/"
echo "Staging running    @ http://front-end.staging.$INGRESS_IP.xip.io/"
echo "Production running @ http://front-end.production.$INGRESS_IP.xip.io/"
cho "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get pods -n dev"
kubectl get pods -n dev
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get pods -n staging"
kubectl get pods -n staging
echo "--------------------------------------------------------------------------"
echo "kubectl get pods -n production"
kubectl get pods -n production
echo "--------------------------------------------------------------------------"
echo "kubectl -n keptn describe configmap keptn-orgs"
kubectl -n keptn describe configmap keptn-orgs
