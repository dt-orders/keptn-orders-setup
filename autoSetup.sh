
#!/bin/bash

clear

if [ -z $1 ]; then
  DEPLOYMENT=gke
fi

./1-installPrerequisitesTools.sh $DEPLOYMENT  2>&1 | tee logs/1-installPrerequisitesTools.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./2-enterInstallationScriptInputs.sh $DEPLOYMENT 2>&1 | tee logs/2-enterInstallationScriptInputs.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./3-provisionInfrastructure.sh $DEPLOYMENT  2>&1 | tee logs/3-provisionInfrastructure.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./4-installKeptn.sh 2>&1 | tee logs/4-installKeptn.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./5-forkApplicationRepositories.sh  2>&1 | tee logs/5-forkApplicationRepositories.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./6-onboardOrderApp.sh  2>&1 | tee logs/6-onboardOrderApp.log
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key