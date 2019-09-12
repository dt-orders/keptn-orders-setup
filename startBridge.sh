#!/bin/bash

clear

echo ""
echo "======================================================================"
echo "Starting Keptn Bridge"
echo "View bridge @ http://$(curl -s ifconfig.me)/#/"
echo ""
while true; do kubectl port-forward svc/bridge -n keptn 9000:8080; done
