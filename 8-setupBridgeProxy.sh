#!/bin/bash

clear
echo "======================================================================"

# Installation of haproxy
if ! [ -x "$(command -v haproxy)" ]; then
  echo "Installing 'haproxy' utility"
  sudo apt update
  sudo apt install haproxy -y
fi

PROXY_USER_PLACEHOLDER=$(cat creds.json | jq -r '.keptnBridgeUser')
PROXY_PASSWORD_PLACEHOLDER=$(cat creds.json | jq -r '.keptnBridgePassword')

echo "Creating new /etc/haproxy/haproxy.cfg"
cat haproxy.template | \
      sed 's~PROXY_USER_PLACEHOLDER~'"$PROXY_USER_PLACEHOLDER"'~' | \
      sed 's~PROXY_PASSWORD_PLACEHOLDER~'"$PROXY_PASSWORD_PLACEHOLDER"'~' > haproxy.cfg
sudo cp haproxy.cfg /etc/haproxy/haproxy.cfg

echo "Restarting haproxy"
sudo service haproxy restart

echo ""
echo "======================================================================"
echo "Start Keptn Bridge with this command:"
echo "while true; do kubectl port-forward svc/$(kubectl get ksvc bridge -n keptn -ojsonpath={.status.latestReadyRevisionName})-service -n keptn 9000:80; done"
echo ""
echo "View bridge @ http://$(curl -s ifconfig.me)/#/"