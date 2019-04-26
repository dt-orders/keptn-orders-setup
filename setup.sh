#!/bin/bash

clear
# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

show_menu(){
echo ""
echo "===================================================="
echo "SETUP MENU"
echo "===================================================="
echo "1)  Install Prerequisites Tools"
echo "2)  Enter Installation Script Inputs"
echo "3)  Provision Infrastructure"
echo "4)  Install Keptn"
echo "5)  Fork Application Repositories"
echo "6)  Onboard Order App"
echo "7)  Import Jenkins Build Pipelines"
echo "----------------------------------------------------"
echo "10)  Validate Kubectl"
echo "11)  Validate Prerequisite Tools"
echo "----------------------------------------------------"
echo "99) Delete Infrastructure"
echo "===================================================="
echo "Please enter your choice or <q> or <return> to exit"
read opt
}

show_menu
while [ opt != "" ]
    do
    if [[ $opt = "" ]]; then 
        exit;
    else
        clear
        case $opt in
        1)
                ./1-installPrerequisitesTools.sh $DEPLOYMENT  2>&1 | tee logs/1-installPrerequisitesTools.log
                show_menu
                ;;
        2)
                ./2-enterInstallationScriptInputs.sh $DEPLOYMENT 2>&1 | tee logs/2-enterInstallationScriptInputs.log
                show_menu
                ;;
        3)
                ./3-provisionInfrastructure.sh $DEPLOYMENT  2>&1 | tee logs/3-provisionInfrastructure.log
                show_menu
                ;;
        4)
                ./4-installKeptn.sh 2>&1 | tee logs/4-installKeptn.log
                show_menu
                ;;
        5)
                ./5-forkApplicationRepositories.sh  2>&1 | tee logs/5-forkApplicationRepositories.log
                show_menu
                ;;
        6)
                ./6-onboardOrderApp.sh  2>&1 | tee logs/6-onboardOrderApp.log
                show_menu
                ;;
        7)
                ./7-importJenkinsBuildPipelines.sh  2>&1 | tee logs/7-importJenkinsBuildPipelines.log
                show_menu
                ;;
        10)
                ./validateKubectl.sh  2>&1 | tee logs/validateKubectl.log
                show_menu
                ;;
        11)
                ./validatePrerequisiteTools.sh $DEPLOYMENT 2>&1 | tee logs/validatePrerequisiteTools.log
                show_menu
                ;;
        99)
                ./deleteInfrastructure.sh  2>&1 | tee logs/deleteInfrastructure.log
                show_menu
                ;;
        q)
           	break
           	;;
        *) 
            	echo "invalid option"
            	show_menu
            	;;
    esac
fi
done