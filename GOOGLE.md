# Google bastion host VM

Below are instructions for using the gcloud CLI to provison an ubuntu virtual machine on Google to use for the cluster, keptn, and application setup.

Assuption is you have a Google project named 'gke-keptn-orders' and will provision the compute instance in zone 'us-east1-c'.  

Recommended image is:
* Ubuntu 16.04 LTS
* amd64 xenial image built on 2019-03-25

You can also make the VM from the console, and the continue with the steps to connect using ssh.

# Create instance

Run this command to create the VM. You need to adjust values for your project. You can optionally adjust zone. [Google docs](https://cloud.google.com/sdk/gcloud/reference/compute/instances/create)
```
gcloud compute instances create "keptn-orders-bastion" \
--project "gke-keptn-orders" \
--zone "us-east1-c" \
--image-project="ubuntu-os-cloud" \
--image-family="ubuntu-1604-lts" \
--machine-type="g1-small"
```

# SSH to VM using gcloud

Run this command to SSH to the new VM.
```
gcloud compute --project "gke-keptn-orders" ssh --zone "us-east1-c" "keptn-orders-bastion"
```

# Initialize gcloud

Within the VM, run this command ```gcloud init```

At the prompt, follow these steps
* Choose option 'Log in with a new account'
* Choose 'Y' to continue using personal account
* Copy the URL to a browser and paste the verification code once you login
* Paste the verification code
* Choose default project
* Choose option to pick default region and zone. For example: [2] us-east1-c"

When complete, run this command ```gcloud config list``` to see your config.

When complete, run this command ```gcloud compute instances list``` to see your VMs

# Clone the Orders setup repo

Within the VM, run these commands to clone the setup repo.

```
git clone https://github.com/keptn-orders/keptn-orders-setup.git

cd keptn-orders-setup
```

Now proceed to the [Installation script for ubuntu](README.md#installation-script-for-ubuntu) step and then the 'Provision Cluster, Install Keptn, and onboard the Orders application' steps.

# Delete the VM

From outside the VM, run this command to delete the VM. [Google docs](https://cloud.google.com/sdk/gcloud/reference/compute/instances/delete)

```
gcloud compute instances delete "keptn-orders-bastion" \
--project "gke-keptn-orders" \
--zone "us-east1-c"
```

# Other gcloud command reference

```
# list available images
gcloud compute images list

# list available machine types
gcloud compute machine-types list
```