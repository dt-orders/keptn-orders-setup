# Google bastion host VM

Below are instructions for using the gcloud CLI to provison an ubuntu virtual machine on Google to use for the cluster, keptn, and application setup.

# Create instance

Run this command to create the VM. [Google docs](https://cloud.google.com/sdk/gcloud/reference/compute/instances/create)
```
gcloud compute instances create "keptn-bastion" \
--project "gke-keptn" \
--zone "us-west1-b" \
--image-project="ubuntu-os-cloud" \
--image-family="ubuntu-1604-lts" \
--machine-type="g1-small"
```

# SSH to VM using gcloud

Run this command to SSH to the new VM.
```
gcloud compute --project "gke-keptn" ssh --zone "us-west1-b" "keptn-bastion"
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

# Delete the VM

From outside the VM, run this command to delete the VM. [Google docs](https://cloud.google.com/sdk/gcloud/reference/compute/instances/delete)

```
gcloud compute instances delete "keptn-bastion" \
--project "gke-keptn" \
--zone "us-west1-b"
```

# Other gcloud command reference

```
# list available images
gcloud compute images list

# list available machine types
gcloud compute machine-types list
```