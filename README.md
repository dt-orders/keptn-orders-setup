# Overview

This repos has the code and scripts to provision and configure a cloud infrastructure running Kubernetes and the [Keptn](http://keptn.sh) components to build, deploy and host a micro service based order processing demo application.

Footnotes:
* Currently, these setup scripts support only AWS.  The plan is to support Azure, RedHat, and Cloud Foundry PaaS platforms.
* GKE uses a docker registry run within the cluster.  It uses the Jenkins docker image is from: https://hub.docker.com/r/keptn/jenkins
* Demo app based on example from: https://github.com/ewolff/microservice-kubernetes

# Pre-requisites

1. Dynatrace - Assumes you will use a trial SaaS dynatrace tenant from https://www.dynatrace.com/trial and have created a PaaS and API token
1. GitHub - Assumes you have a github account and have created a new github organization
1. Cloud provider account.  Highly recommend to sign up for personal free trial as to have full admin rights and to not cause any issues with your enterprise account. Links to free trials
   * GKE - https://cloud.google.com/free/
   * AWS - https://aws.amazon.com/free/
   * Azure - https://azure.microsoft.com/en-us/free/
   * OpenShift - https://www.openshift.com/trial/

# Setup

Run each script in the order listed below.  Note that some scripts require a argument as to accomoidate to specify the Cloud provider hosting the cluster. This argument will drive specific logic. 

Valid [deployment type]argument values are:
* eks = AWS
* aks = Azure
* ocp = Open Shift
* gke = Google

NOTE: Logs from each script can be found in ```logs/``` subfolder.

## 1. Install Prerequisites Tools

Run ```./1-installPrerequisitesTools.sh [deployment type]``` to install the required  unix tools such as kubectl, jq, cloud provider CLI.

## 2. Define Workshop Inputs

Before you do this step, be prepared with your github credentials, dynatrace tokens, and cloud provider project information.

Run ```./2-defineWorkshopInputs.sh [deployment type]``` to inputted values that are referenced in the remaining setup scripts. Inputted values are stored in ```creds.json``` file.  

## 3. ProvisionInfrastructure

Run ```./3-provisionInfrastructure.sh [deployment type]``` to provision the Cluster on the specified cloud deployment type.

## 4. Install Keptn

Run ```./4-installKeptn.sh [branch]``` to install Keptn control plane components into your cluster.  This script will:
1. clone https://github.com/keptn/keptn into the a keptn subfolder.  The [branch] parameter is used to 
sepecify what branch to use. 
1. copy the values we already captured in the ```2-defineWorkshopInputs.sh``` script and use then toe create the creds.json file and the creds_dt.json expected by ```keptn/install/scripts/defineCredentials.sh``` and ```defineDynatraceCredentials.sh``` scripts
1. run the ```keptn/install/scripts/defineCredentials.sh``` and ```defineDynatraceCredentials.sh``` scripts
1. run the ```showKeptn.sh```, ```showDynatrace.sh``` and ```showJenkins.sh``` helper scripts

## 5. Fork Application Repositories

Run ```./5-forkApplicationRepositories.sh``` to fork the orders application into the github organization you specified when you called ```2-defineWorkshopInputs.sh```.  This script will:
* delete and created a local respositories/ folder
* clone the orders application repositories
* use the ```hub``` utility to fork each repositories
* push each repository to your personal github organization

## 6. Onboard Order App

Run ```./6-onboardOrderApp.sh``` to onboard the orders application using the ```keptn``` CLI tool and the onboarding files found in the ```keptn-onboarding/``` folder.

## 7. Import Jenkins Build Pipelines

Optionally run ```./7-importJenkinsBuildPipelines``` to import Jenkins build pipelines for each service of the orders application.  When the build pushed an image to the docker registry, a keptn events will be created which automatically runs the keptn deploy pipeline for that service.

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
```

# Remove cluster

Fastest way to remove everything is to delete your cluster using this script.

```./deleteInfrastructure.sh [deployment type]```