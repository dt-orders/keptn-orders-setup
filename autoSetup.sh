
#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

clear

./1-installPrerequisitesTools.sh $DEPLOYMENT  2>&1 | tee logs/1-installPrerequisitesTools.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./2-enterInstallationScriptInputs.sh $DEPLOYMENT 2>&1 | tee logs/2-enterInstallationScriptInputs.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./3-provisionInfrastructure.sh $DEPLOYMENT  2>&1 | tee logs/3-provisionInfrastructure.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./4-installKeptn.sh 2>&1 | tee logs/4-installKeptn.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./5-installDynatrace.sh $DEPLOYMENT 2>&1 | tee logs/5-installDynatrace.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./6-forkApplicationRepositories.sh 2>&1 | tee logs/6-forkApplicationRepositories.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./7-onboardOrderApp.sh 2>&1 | tee logs/7-onboardOrderApp.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./8-setupBridgeProxy.sh 2>&1 | tee logs/8-setupBridgeProxy.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key