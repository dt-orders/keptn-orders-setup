#!/bin/bash

# load in the shared library and validate argument
. ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/1-installPrerequisitesTools.log)
exec 2>&1

clear
echo "===================================================="
echo "About to install required tools"
echo "Deployment Type: $DEPLOYMENT"
echo ""
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key

# save current directory for restoration later in script
CURRENT_DIR=$(pwd)

# executable files will be copied here if required
mkdir -p $HOME/bin
export PATH=$HOME/bin:$PATH
echo "export PATH=$HOME/bin:$PATH" >> ~/.bashrc

# change to users home directory
cd ~

# Installation of hub
if ! [ -x "$(command -v hub)" ]; then
  echo "----------------------------------------------------"
  echo "Downloading git 'hub' utility ..."
  rm -rf hub-linux-amd64-2.10.0*
  wget https://github.com/github/hub/releases/download/v2.10.0/hub-linux-amd64-2.10.0.tgz
  tar -zxvf hub-linux-amd64-2.10.0.tgz
  echo "Installing git 'hub' utility ..."
  sudo ./hub-linux-amd64-2.10.0/install
  rm -rf hub-linux-amd64-2.10.0*
fi

# Installation of jq
if ! [ -x "$(command -v jq)" ]; then
  echo "----------------------------------------------------"
  echo "Installing git 'jq' utility ..."
  #sudo yum -y install jq
  wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
  chmod +x jq
  mv ./jq $HOME/bin/jq
fi

# Installation of kubectl
if ! [ -x "$(command -v kubectl)" ]; then
  echo "----------------------------------------------------"
  echo "Downloading 'kubectl' ..."
  curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/kubectl 
  echo "Installing 'kubectl' ..."
  chmod +x ./kubectl
  mv ./kubectl $HOME/bin/kubectl
fi

case $DEPLOYMENT in
  eks)
    # AWS specific tools
    if ! [ -x "$(command -v aws-iam-authenicator)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'aws-iam-authenticator' ..."
      https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
      rm aws-iam-authenticator
      curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
      echo "Installing 'aws-iam-authenticator' ..."
      chmod +x ./aws-iam-authenticator
      mv ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator 
    fi
    # eksctl - used to provison eks cluster
    # TODO: replace with https://eksctl.io/
    # if ! [ -x "$(command -v terraform)" ]; then
    #   echo "----------------------------------------------------"
    #   echo "Downloading 'terraform' ..."
    #   rm -rf terraform_0.11.13_linux_amd64*
    #   rm -rf terraform
    #   wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
    #   echo "Installing 'terraform' ..."
    #   unzip terraform_0.11.13_linux_amd64.zip
    #   sudo cp terraform $HOME/bin/terraform
    # fi
    ;;
  ocp)
    # Openshift specific tools
    if ! [ -x "$(command -v oc)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'oc' ..."
      wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz 
      echo "Installing 'oc' ..."
      tar xzf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
      cd openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit
      chmod +x oc
      mv oc $HOME/bin/oc
      rm -rf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit* 
    fi
    ;;
  aks)
    # Azure specific tools
    # https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum?view=azure-cli-latest
    if ! [ -x "$(command -v az)" ]; then
      echo "----------------------------------------------------"
      echo "Import the Microsoft repository key ..."
      sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      echo "Create local azure-cli repository information ..."
      sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
      echo "Install azure-cli ..."
      sudo yum install azure-cli
      echo "Login to Azure ..."
      az login
      echo "Update the Azure CLI ..."
      sudo yum update azure-cli
    fi
    ;;
  gke)
    # Google specific tools
    if ! [ -x "$(command -v gcloud)" ]; then
      echo "TODO: add in GCLOUD CLI"
    fi
    ;;
esac

echo ""
echo "===================================================="
echo "Installation complete."
echo "===================================================="

# run a final validation
cd $CURRENT_DIR
./validatePrerequisiteTools.sh $DEPLOYMENT
