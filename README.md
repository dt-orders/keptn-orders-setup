# Overview

This repos has the code and scripts to provision and configure a cloud infrastructure running Kubernetes and the [Keptn](http://keptn.sh) components to build, deploy and host a micro service based order processing demo application.

<img src="images/orders.png" width="300"/>

Footnotes:
* Built using [Keptn 0.2.1](https://keptn.sh/docs/0.2.1/installation/) 
* Currently, these setup scripts support only Google GKE and coming soon Amazon EKS.  The plan is to then support Azure, RedHat, and Cloud Foundry PaaS platforms.
* GKE uses a docker registry run within the cluster.  
* Demo app based on example from: https://github.com/ewolff/microservice-kubernetes

# Pre-requisites

## 1. Accounts

1. Dynatrace - Assumes you will use a trial SaaS dynatrace tenant from https://www.dynatrace.com/trial and create a PaaS and API token
1. GitHub - Assumes you have a github account and have created a new github organization
1. Cloud provider account.  Highly recommend to sign up for personal free trial as to have full admin rights and to not cause any issues with your enterprise account. Links to free trials
   * GKE - https://cloud.google.com/free/

## 2. Tools

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

# Bastion host setup

See these instructions for provisioning an ubuntu 16.04 LTS host on the targeted cloud provider.
* [Google Compute Engine VM](GOOGLE.md)

# Provision Cluster, Install Keptn, and onboard the Orders application

There are multiple scripts used for the setup and they must be run the right order.  Just run the setup script that will prompt you with menu choices.
```
./setup.sh <deployment type>
```
NOTE: Valid 'deployment type' argument values are:
* gke = Google

The setup menu should look like this:
```
====================================================
SETUP MENU
====================================================
1)  Install Prerequisites Tools
2)  Enter Installation Script Inputs
3)  Provision Infrastructure
4)  Install Keptn
5)  Fork Application Repositories
6)  Onboard Order App
7)  Import Jenkins Build Pipelines
----------------------------------------------------
10)  Validate Kubectl
11)  Validate Prerequisite Tools
----------------------------------------------------
99) Delete Infrastructure
====================================================
Please enter your choice or <q> or <return> to exit

```

NOTE: each script will log the console output into the ```logs/``` subfolder.


## 1) Install Prerequisites Tools

This will install the required unix tools such as kubectl, jq, cloud provider CLI.

At the end if the installation, the Sscript will call the 'Validate Prerequisite Tools' script that will verify tools setup setup.  

You can re-run both 'Install Prerequisites Tools' or 'Validate Prerequisite Tools' anytime as required.

## 2) Enter Installation Script Inputs

Before you do this step, be prepared with your github credentials, dynatrace tokens, and cloud provider project information available.

This will prompt you for values that are referenced in the remaining setup scripts. Inputted values are stored in ```creds.json``` file.  

## 3) Provision Kubernetes cluster

This will provision a Cluster on the specified cloud deployment type. This script will take several minutes to run and you can verify the cluster was created with the the cloud provider console.

This script at the end will run the 'Validate Kubectl' script.  

## 4) Install Keptn

This will install the Keptn control plane components into your cluster.  

Internally, this script will take several minutes to run and will perform the following:
1. clone https://github.com/keptn/keptn into the a keptn subfolder.  The keptn branch the script uses is specified in the ```creds.json``` file.
1. copy the values we already captured in the ```2-defineWorkshopInputs.sh``` script and use then toe create the creds.json file and the creds_dt.json expected by ```keptn/install/scripts/defineCredentials.sh``` and ```defineDynatraceCredentials.sh``` scripts
1. run the ```keptn/install/scripts/defineCredentials.sh``` and ```defineDynatraceCredentials.sh``` scripts
1. run the 'Show Keptn', 'Show Dynatrace' and 'Show Jenkins' helper scripts

## 5) Fork Order application repositories

This will fork the orders application into the github organization you specified when you called 'Enter Installation Script Inputs' step.  

Internally, this script will:
1. delete and created a local respositories/ folder
1. clone the orders application repositories
1. use the ```hub``` unix git utility to fork each repositories
1. push each repository to your personal github organization

## 6) Onboard Order application

This script will onboard the orders application using the ```keptn``` CLI tool and the keptn onboarding files found in the ```keptn-onboarding/``` folder.  

Internally, this script will:
* keptn create project
* keptn onboard service

You can verify the onbaording was complete by reviewing the 'orders-project' within your personal git org.

## 7) Import Jenkins build pipelines

This script will import Jenkins build pipelines for each service of the orders application.  When the build pushed an image to the docker registry, a keptn events will be created which automatically runs the keptn deploy pipeline for that service.

# Other setup related scripts

These are additional scripts available in the 'setup.sh' menu.

## 10)  Validate Kubectl

This script will attempt to 'get pods' using kubectl. 

## 11)  Validate Prerequisite Tools

This script will look for the existence of required prerequisite tools.  It does NOT check for version just the existence of the script. 

## 99) Remove Kubernetes cluster

Fastest way to remove everything is to delete your cluster using this script.  Becare when you run this as to not lose your work.

# Helpful scripts

These scripts are helpful when using and reviewing status of your environment.  Just run the helper script that will prompt you with menu choices.
```
./helper.sh
```

The helper menu should look like this:
```
====================================================
HELPER MENU
====================================================
1) show App
2) show Jenkins
3) show Keptn
4) show Dyntrace
----------------------------------------------------
5) Get Kibana Commands (gke)
6) Configure Gcloud (gke)
====================================================
Please enter your choice or <q> or <return> to exit

```

NOTE: each script will log the console output into the ```logs/``` subfolder.

## 1) Show app

Displays the deployed orders application pods and urls

## 2) show Jenkins

Displays the Keptn pods and ingress gateway

## 3) Show Keptn

Displays the Dynatrace pods and Dynatrace Kube secrets file

## 4) Show Dyntrace

Displays the URL to the running Jenkins server

## 5) Get Kibana Commands (gke) -- for Google gcloud only

Script will read creds.json file for values and display the commands that can be 'cut-n-pasted' to your laptop to configure kubectl as to allow starting the kibana to view keptn event logs.

## 6) Configure Gcloud (gke) -- for Google gcloud only
Script will read creds.json file for values and display the commands that can be 'cut-n-pasted' to your laptop if you are running gcloud from there.  

