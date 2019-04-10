#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/1-installPrerequisitesTools.log)
exec 2>&1

# verify first running on Ubuntu for the installation scripts
# assume that
if [ "$(uname -a | grep Ubuntu)" == "" ]; then
  echo "Must be running on Ubuntu to run this script"
  exit 1
fi

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

# specify versions to install
KEPTN_CLI_VERSION=v0.2.x-prerelease
HUB_VERSION=2.11.1
JQ_VERSION="latest stable"
# eks
EKS_KUBECTL_VERSION=1.11.5
EKS_IAM_AUTHENTICATOR_VERSION=1.11.5
EKS_EKSCTL_VERSION=latest_release
# gke
GKE_CLOUD_VERSION="latest stable"
GKE_KUBECTL_VERSION="latest stable"

clear
echo "======================================================================"
echo "About to install required tools"
echo "Deployment Type: $DEPLOYMENT"
echo ""
echo "NOTE: this will download and copy the executable into /usr/local/bin"
echo "      if the utility finds a value when running 'command -v <utility>'"
echo "      that utility will be concidered already installed"
echo ""
echo "Versions to be installed if not already:"
echo "  KEPTN_CLI_VERSION             : $KEPTN_CLI_VERSION"
echo "  HUB_VERSION                   : $HUB_VERSION"
echo "  JQ_VERSION                    : $JQ_VERSION"
case $DEPLOYMENT in
  eks)
    echo "  EKS_IAM_AUTHENTICATOR_VERSION : $EKS_IAM_AUTHENTICATOR_VERSION"
    echo "  EKS_KUBECTL_VERSION           : $EKS_KUBECTL_VERSION"
    echo "  EKS_EKSCTL_VERSION            : $EKS_EKSCTL_VERSION"
    ;;
  gke)
    echo "  GKE_CLOUD_VERSION             : $GKE_CLOUD_VERSION"
    echo "  GKE_KUBECTL_VERSION           : $GKE_KUBECTL_VERSION"
    ;;
  aks)
    ;;
  ocp)
    ;;
esac
echo "======================================================================"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

# first get latest list of packages
sudo apt-get update

# Installation of keptn cli
# https://github.com/github/hub/releases
if ! [ -x "$(command -v keptn)" ]; then
  echo "----------------------------------------------------"
  echo "Downloading git 'keptn' utility ..."
  rm -rf keptn-linux*
  wget https://github.com/keptn/keptn/releases/download/$KEPTN_CLI_VERSION/keptn-linux.tar.gz
  tar -zxvf keptn-linux.tar.gz
  echo "Installing git 'keptn' utility ..."
  chmod +x keptn
  sudo mv keptn /usr/local/bin/keptn
fi

# Installation of hub
# https://github.com/github/hub/releases
if ! [ -x "$(command -v hub)" ]; then
  echo "----------------------------------------------------"
  echo "Downloading git 'hub' utility ..."
  rm -rf hub-linux-amd64-$HUB_VERSION*
  wget https://github.com/github/hub/releases/download/v$HUB_VERSION/hub-linux-amd64-$HUB_VERSION.tgz
  tar -zxvf hub-linux-amd64-$HUB_VERSION.tgz
  echo "Installing git 'hub' utility ..."
  sudo ./hub-linux-amd64-$HUB_VERSION/install
  rm -rf hub-linux-amd64-$HUB_VERSION*
fi

# Installation of jq
# https://github.com/stedolan/jq/releases
if ! [ -x "$(command -v jq)" ]; then
  echo "----------------------------------------------------"
  echo "Installing git 'jq' utility ..."
  sudo apt-get --assume-yes install jq
fi

case $DEPLOYMENT in
  eks)
    # Installation of kubectl
    if ! [ -x "$(command -v kubectl)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'kubectl' ..."
      curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/$EKS_KUBECTL_VERSION/2018-12-06/bin/linux/amd64/kubectl 
      echo "Installing 'kubectl' ..."
      chmod +x ./kubectl
      sudo mv ./kubectl /usr/local/bin/kubectl
    fi
    # AWS specific tools
    if ! [ -x "$(command -v aws-iam-authenicator)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'aws-iam-authenticator' ..."
      https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
      rm aws-iam-authenticator
      curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/$EKS_IAM_AUTHENTICATOR_VERSION/2018-12-06/bin/linux/amd64/aws-iam-authenticator
      echo "Installing 'aws-iam-authenticator' ..."
      chmod +x ./aws-iam-authenticator
      sudo mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator 
    fi
    # eksctl - utility used to provison eks cluster
    if ! [ -x "$(command -v eksctl)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'eksctl' ..."
      rm -rf eksctl*.tar.gz
      rm -rf eksctl
      curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/$EKS_EKSCTL_VERSION/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C .
      sudo mv eksctl /usr/local/bin/eksctl
    fi
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
      mv oc /usr/local/bin/oc
      rm -rf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit* 
    fi
    ;;
  aks)
    # TODO: don't use YUM
    # Azure specific tools
    # https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum?view=azure-cli-latest
    # if ! [ -x "$(command -v az)" ]; then
    #   echo "----------------------------------------------------"
    #   echo "Import the Microsoft repository key ..."
    #   sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    #   echo "Create local azure-cli repository information ..."
    #   sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
    #   echo "Install azure-cli ..."
    #   sudo yum install azure-cli
    #   echo "Login to Azure ..."
    #   az login
    #   echo "Update the Azure CLI ..."
    #   sudo yum update azure-cli
    # fi
    if ! [ -x "$(command -v az)" ]; then
      echo "TODO: add in AZ CLI"
    fi
    ;;
  gke)
    # Google specific tools
    if ! [ -x "$(command -v gcloud)" ]; then
      echo "----------------------------------------------------"
      echo "Installing gcloud"
      GKE_SDK=google-cloud-sdk-241.0.0-linux-x86_64.tar.gz
      rm -rf $GKE_SDK
      rm -rf google-cloud-sdk/
      curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$GKE_SDK
      tar zxvf $GKE_SDK google-cloud-sdk
      ./google-cloud-sdk/install.sh
    fi

    # Google specific tools
    if ! [ -x "$(command -v kubectl)" ]; then
      echo "----------------------------------------------------"
      echo "Installing kubectl"
      # https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl
      curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
      echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
      sudo apt-get update
      sudo apt-get install -y kubectl
    fi
    ;;
esac

echo ""
echo "===================================================="
echo "Installation complete."
echo "===================================================="

# run a final validation
./validatePrerequisiteTools.sh $DEPLOYMENT

if [ $DEPLOYMENT == "gke"]
  echo "===================================================="
  echo "If you have not done so already, run this command"
  echo "to configure gcloud"
  echo ""
  echo "gcloud init"
  echo "===================================================="
fi