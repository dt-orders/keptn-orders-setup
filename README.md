# Overview

This repos has the code and scripts to provision and configure a cloud infrastructure running Kubernetes and the [Keptn](http://keptn.sh) components to build, deploy and host a micro service based order processing demo application.

<img src="images/orders.png" width="300"/>

Footnotes:
* Built using [Keptn release-0.2.x](https://github.com/keptn/keptn/tree/release-0.2.x) 
* Currently, these setup scripts support only Google GKE and coming soon Amazon EKS.  The plan is to then support Azure, RedHat, and Cloud Foundry PaaS platforms.
* GKE uses a docker registry run within the cluster.  
* Demo app based on example from: https://github.com/ewolff/microservice-kubernetes

# Pre-requisites

## Accounts

1. Dynatrace - Assumes you will use a trial SaaS dynatrace tenant from https://www.dynatrace.com/trial and have created a PaaS and API token
1. GitHub - Assumes you have a github account and have created a new github organization
1. Cloud provider account.  Highly recommend to sign up for personal free trial as to have full admin rights and to not cause any issues with your enterprise account. Links to free trials
   * GKE - https://cloud.google.com/free/
   * AWS - https://aws.amazon.com/free/
   * Azure - https://azure.microsoft.com/en-us/free/
   * OpenShift - https://www.openshift.com/trial/

## Tools

The following set of tools are required by the installation scripts and interacting with the environment.

All platforms
* keptn -[CLI to manage Keptn projects](https://keptn.sh/docs/0.2.0/reference/cli/)
* helm - [Package manager for Kubernetes](https://helm.sh/)
* jq - [Json query utility to suport parsing](https://stedolan.github.io/jq/)
* yq - [Yaml query utility to suport parsing](https://github.com/mikefarah/yq)
* hub - [git utility to support command line forking](https://github.com/github/hub)
* kubectl - [CLI to manage the cluster](https://kubernetes.io/docs/tasks/tools/install-kubectl). This is required for all, but will use the installation instructions per each cloud provider

Google additional tools
* gcloud - [CLI for Google Cloud](https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu)

Amazon additional tools
* aws - [CLI for AWS](https://aws.amazon.com/cli/)
* ekscli - [CLI for Amazon EKS](https://eksctl.io/)
* aws-iam-authenticator - [Provides authentication kubectl to the eks cluster](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

Azure additional tools
* az - [CLI for Azure](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest)

OpenShift additional tools
* oc - [CLI for OpenShift](https://docs.openshift.com/enterprise/3.0/cli_reference/get_started_cli.html)

# Setup

## Ubuntu host for running scripts

The following script can be used if you are running ubuntu.  It has been tested with ubuntu 16.04 LTS.

It is recommended you provision a cloud VM, SSH into it, clone this repo and run scripts from it.  See these instructions for the targeted cloud provider.
* [Google Compute Engine VM](GOOGLE.md)
* [AWS EC2 VM](AWS.md) 
* [AZURE VM](AZURE.md) 

Run each script in the order listed below.  Logs from each script can be found in ```logs/``` subfolder.

Note that some scripts require a 'deployment type' argument as to accomoidate to specify the Cloud provider hosting the cluster. This argument will drive specific logic. 

Valid 'deployment type' argument values are:
* eks = AWS
* aks = Azure
* ocp = Open Shift
* gke = Google

## Installation script for ubuntu

The following script can be used if you are running ubuntu.  It has been tested with ubuntu 16.04 LTS and assumes the following are available: apt-get, curl and wget.

If you do not have ubuntu, then just provision a cloud VM and clone this repo onto it.  From there run this tools install script and move onto the steps to provision the cluster, install Keptn, and onboard the Orders application.

Run ```./1-installPrerequisitesTools.sh [deployment type]``` to install the required unix tools such as kubectl, jq, cloud provider CLI. Script will call ```validatePrerequisiteTools.sh``` at the end to verify setup.

# Provision Cluster, Install Keptn, and onboard the Orders application

## Enter installation script inputs

Before you do this step, be prepared with your github credentials, dynatrace tokens, and cloud provider project information available.

Run ```./2-enterInstallationScriptInputs.sh [deployment type]``` to input values that are referenced in the remaining setup scripts. Inputted values are stored in ```creds.json``` file.  

## Provision Kubernetes cluster

Run ```./3-provisionInfrastructure.sh [deployment type]``` to provision the Cluster on the specified cloud deployment type.

## Install Keptn

Run ```./4-installKeptn.sh``` to install Keptn control plane components into your cluster.  This script will:
1. clone https://github.com/keptn/keptn into the a keptn subfolder.  The keptn branch the script uses is specified in the ```creds.json``` file.
1. copy the values we already captured in the ```2-defineWorkshopInputs.sh``` script and use then toe create the creds.json file and the creds_dt.json expected by ```keptn/install/scripts/defineCredentials.sh``` and ```defineDynatraceCredentials.sh``` scripts
1. run the ```keptn/install/scripts/defineCredentials.sh``` and ```defineDynatraceCredentials.sh``` scripts
1. run the ```showKeptn.sh```, ```showDynatrace.sh``` and ```showJenkins.sh``` helper scripts

## Fork Order application repositories

Run ```./5-forkApplicationRepositories.sh``` to fork the orders application into the github organization you specified when you called ```2-defineWorkshopInputs.sh```.  This script will:
1. delete and created a local respositories/ folder
1. clone the orders application repositories
1. use the ```hub``` utility to fork each repositories
1. push each repository to your personal github organization

## Onboard Order application

Run ```./6-onboardOrderApp.sh``` to onboard the orders application using the ```keptn``` CLI tool and the onboarding files found in the ```keptn-onboarding/``` folder.  It will call:
* keptn create project
* keptn onboard service

## Import Jenkins build pipelines

Run ```./7-importJenkinsBuildPipelines``` to import Jenkins build pipelines for each service of the orders application.  When the build pushed an image to the docker registry, a keptn events will be created which automatically runs the keptn deploy pipeline for that service.

# Helpful scripts

These scripts are helpful when using and reviewing status of your environment. To try out the scripts just run these commands
```
# show the deployed application
./showApp.sh

# show the Keptn pods and ingress gateway
./showKeptn.sh

# show the Dynatrace pods and Dynatrace Kube secrets file
./showDynatrace.sh

# show the URL to the running Jenkins server
./showJenkins.sh

# for Google gcloud only - configures gcloud connection with values in creds.json
# as to allow kubectl to connect to cluster
# reads creds.json file, so run this script bastion host then
# run commands on laptop or allow this script to just run them
./gkeConfigureGcloud.sh

# for Google gcloud only - get the commands to run Kibana locally
# reads creds.json file, so run this script from bastion host then
# run commands on laptop
./gkeGetKibanaCommands
```

# Remove Kubernetes cluster

Fastest way to remove everything is to delete your cluster using this script.

```./deleteInfrastructure.sh [deployment type]```