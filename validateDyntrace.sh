#!/bin/bash

echo "-------------------------------------------------------"
echo Validating Dynatrace 
echo "-------------------------------------------------------"

export DT_TENANT_HOSTNAME=$(cat creds.json | jq -r '.dynatraceHostName')
export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
export DT_PAAS_TOKEN=$(cat creds.json | jq -r '.dynatracePaaSToken')


if [ $DT_TENANT_HOSTNAME == "DT_TENANT_HOSTNAME_PLACEHOLDER" ]
then
  echo DT_TENANT_HOSTNAME is not set properly.
  exit 1
fi
if [ $DT_API_TOKEN == "DYNATRACE_API_TOKEN" ]
then
  echo DT_API_TOKEN is not set properly.
  exit 1
fi
if [ $DT_PAAS_TOKEN == "DYNATRACE_PAAS_TOKEN" ]
then
  echo DT_PAAS_TOKEN is not set properly.
  exit 1
fi

echo ""
echo "----------------------------------------------------------"
echo Validating Dynatrace PaaS token is configured properly ...
echo "----------------------------------------------------------"
export DT_URL="https://$DT_TENANT_HOSTNAME/api/v1/time?Api-Token=$DT_PAAS_TOKEN"
if [ "$(curl -sL -w '%{http_code}' $DT_URL -o /dev/null)" != "200" ]

then
    echo ">>> Unable to connect using Dynatrace PaaS token.  Verify you have the right token and environment ID (aka tenant)"
    echo ""
    exit 1
fi
echo "Able to connect using Dynatrace PaaS token."
echo ""
echo "----------------------------------------------------------"
echo Validating Dynatrace API token is configured properly ...
echo "----------------------------------------------------------"
export DT_URL="https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags?Api-Token=$DT_API_TOKEN"
if [ "$(curl -sL -w '%{http_code}' $DT_URL -o /dev/null)" != "200" ]
then
    echo ">>> Unable to connect using API Token.  Verify you have the right API Token"
    echo ""
    exit 1
fi
echo "Able to connect using Dynatrace API Token."
echo ""
echo "-------------------------------------------------------"
echo Dynatrace valdiation complete
echo "-------------------------------------------------------"
echo ""