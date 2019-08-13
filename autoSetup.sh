
#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

clear

echo "First copy in your creds.json file"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./2-enterInstallationScriptInputs.sh $DEPLOYMENT 2>&1 | tee logs/2-enterInstallationScriptInputs.log

./1-installPrerequisitesTools.sh $DEPLOYMENT skip 2>&1 | tee logs/1-installPrerequisitesTools.log

./3-provisionInfrastructure.sh $DEPLOYMENT skip  2>&1 | tee logs/3-provisionInfrastructure.log

./4-installKeptn.sh $DEPLOYMENT skip 2>&1 | tee logs/4-installKeptn.log

./5-installDynatrace.sh $DEPLOYMENT skip 2>&1 | tee logs/5-installDynatrace.log

./6-forkApplicationRepositories.sh skip  2>&1 | tee logs/6-forkApplicationRepositories.log

./7-onboardOrderApp.sh skip  2>&1 | tee logs/7-onboardOrderApp.log

./8-setupBridgeProxy.sh 2>&1 | tee logs/8-setupBridgeProxy.log
