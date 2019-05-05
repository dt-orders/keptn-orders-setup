#!/bin/bash

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
KEPTN_CLI_VERSION=0.2.0
HUB_VERSION=2.11.1
HELM_VERSION=2.12.3
# eks
EKS_KUBECTL_VERSION=1.11.5
EKS_IAM_AUTHENTICATOR_VERSION=1.11.5
EKS_EKSCTL_VERSION=latest_release
# aks
# az aks get-versions --location eastus --output table
AKS_KUBECTL_VERSION=1.11.9

clear
echo "======================================================================"
echo "About to install required tools"
echo "Deployment Type: $DEPLOYMENT"
echo ""
echo "NOTE: this will download and copy the executable into /usr/local/bin"
echo "      if the utility finds a value when running 'command -v <utility>'"
echo "      that utility will be concidered already installed"
echo ""
echo "Named Versions to be installed:"
echo "  KEPTN_CLI_VERSION             : $KEPTN_CLI_VERSION"
echo "  HUB_VERSION                   : $HUB_VERSION"
echo "  HELM_VERSION                  : $HELM_VERSION"
case $DEPLOYMENT in
  eks)
    echo "  EKS_IAM_AUTHENTICATOR_VERSION : $EKS_IAM_AUTHENTICATOR_VERSION"
    echo "  EKS_KUBECTL_VERSION           : $EKS_KUBECTL_VERSION"
    echo "  EKS_EKSCTL_VERSION            : $EKS_EKSCTL_VERSION"
    ;;
esac
echo "======================================================================"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

# Installation of keptn cli
# https://keptn.sh/docs/0.2.0/reference/cli/
if ! [ -x "$(command -v keptn)" ]; then
  echo "----------------------------------------------------"
  echo "Downloading 'keptn' utility ..."
  rm -rf keptn-linux*
  wget https://github.com/keptn/keptn/releases/download/$KEPTN_CLI_VERSION/keptn-linux.tar.gz
  tar -zxvf keptn-linux.tar.gz
  echo "Installing 'keptn' utility ..."
  chmod +x keptn
  sudo mv keptn /usr/local/bin/keptn
fi

# Installation of helm
# https://helm.sh/docs/using_helm/#from-the-binary-releases
if ! [ -x "$(command -v helm)" ]; then
  echo "----------------------------------------------------"
  echo "Downloading 'helm' utility ..."
  rm -rf helm-v$HELM_VERSION-linux-amd64.tar.gz
  wget https://storage.googleapis.com/kubernetes-helm/helm-v$HELM_VERSION-linux-amd64.tar.gz
  tar -zxvf helm-v$HELM_VERSION-linux-amd64.tar.gz
  echo "Installing 'helm' utility ..."
  sudo mv linux-amd64/helm /usr/local/bin/helm
  sudo mv linux-amd64/tiller /usr/local/bin/tiller
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
  echo "Installing 'jq' utility ..."
  sudo apt-get update
  sudo apt-get --assume-yes install jq
fi

# Installation of jq
# https://github.com/mikefarah/yq
if ! [ -x "$(command -v yq)" ]; then
  sudo add-apt-repository ppa:rmescandon/yq -y
  sudo apt update
  sudo apt install yq -y
fi

case $DEPLOYMENT in
  eks)
    # AWS CLI
    if ! [ -x "$(command -v aws)" ]; then
      echo "----------------------------------------------------"
      echo "Installing 'aws cli' ..."
      sudo apt install awscli -y
    fi
    # kubectl
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
    # kubectl
    if ! [ -x "$(command -v kubectl)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'kubectl' ..."
      sudo az aks install-cli --client-version $AKS_KUBECTL_VERSION
    fi
    # az cli
    # https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
    if ! [ -x "$(command -v az)" ]; then
      echo "----------------------------------------------------"
      echo "Get packages needed for the install process"
      sudo apt-get update
      sudo apt-get install curl apt-transport-https lsb-release gpg
      echo "Download and install the Microsoft signing key"
      curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor | \
      sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
      echo "Add the Azure CLI software repository"
      AZ_REPO=$(lsb_release -cs)
      echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
      sudo tee /etc/apt/sources.list.d/azure-cli.list
      echo "Update repository information and install the azure-cli package"
      sudo apt-get update
      sudo apt-get install azure-cli
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

case $DEPLOYMENT in
  eks)
    echo ""
    echo "****************************************************"
    echo "****************************************************"
    echo "If you have not done so already, run this command"
    echo "to configure the aws cli"
    echo ""
    echo "aws configure"
    echo "  enter your AWS Access Key ID"
    echo "  enter your AWS Secret Access Key ID"
    echo "  enter Default region name example us-east-1"
    echo "  Default output format, enter json"
    echo "****************************************************"
    echo "****************************************************"
    ;;
  gke)
    echo ""
    echo "****************************************************"
    echo "****************************************************"
    echo "If you have not done so already, run this command"
    echo "to configure gcloud:"
    echo ""
    echo "'gcloud init'"
    echo "  Choose option '[2] Log in with a new account'"
    echo "  Choose 'Y' for 'Are you sure you want to "
    echo "     authenticate with your personal account?'"
    echo "  Copy the URL to a browser and copy the verification code once you login"
    echo "  Paste the verification code"
    echo "  Choose default project"
    echo "  Choose 'Y' for 'Do you want to configure a "
    echo "     default Compute Region and Zone?'"
    echo "  Choose option to pick default region and zone"
    echo "    for example: [2] us-east1-c"
    echo ""
    echo "  Run 'gcloud config list' to view what you entered."
    echo "****************************************************"
    echo "****************************************************"
    ;;
  aks)
    echo ""
    echo "****************************************************"
    echo "****************************************************"
    echo "If you have not done so already, run this command"
    echo "to login into azure. running 'az account list'"
    echo "will show your accounts if you are already logged in"
    echo ""
    echo "az login"
    echo "  This will ask you to open a browser with a code"
    echo "  and then login."
    echo "****************************************************"
    echo "****************************************************"
    ;;
esac