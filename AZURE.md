# Azure bastion host VM

Below are instructions for using the Azure CLI to provison an ubuntu virtual machine on Azure to use for the cluster, keptn, and application setup.

Recommended image is:
* Ubuntu 16.04 LTS

You can also make the VM from the console, and the continue with the steps to connect using ssh.

# Create instance

Run this command to create the VM. You need to adjust values for your project. [Azure docs](https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-create)
```
# login to your account.  This will ask you to open a browser with a code and then login.
az login

# verify you are on the right subscription.  Look for "isDefault": true
az account list --output table

# create a resource group.  You can optionally adjust the location.
az group create --name keptn-orders-group --location eastus

# create the VM
az vm create \
  --name keptn-orders-bastion \
  --resource-group keptn-orders-bastion \
  --size Standard_B1s \
  --image Canonical:UbuntuServer:16.04-LTS:latest \
  --generate-ssh-keys \
  --output json \
  --verbose
```

# SSH to VM using gcloud

Goto the Azure console and choose the "connect" menu on the VM row to copy the connection string. Run this command to SSH to the new VM.
```
ssh <your id>@<host ip>
```

# Clone the Orders setup repo

Within the VM, run these commands to clone the setup repo.
```
git clone https://github.com/keptn-orders/keptn-orders-setup.git

cd keptn-orders-setup
```

# Delete the Bastion resource group and VM from the Azure console

On the resource group page, delete the resource group named 'keptn-orders-group'. 
This will delete the bastion host resource group and the VM running in it.

# Delete the Bastion resource group and VM with the azure cli

from outside the VM, run this command to delete the resource group named 'keptn-orders-group'. 
This will delete the bastion host resource group and the VM running in it.
```
az group delete --name keptn-orders-bastion --yes
```

# az command reference

```
# list of locations
az account list-locations -o table

# list vm VMs
az vm show --name keptn-orders-bastion

# list vm sizes
az vm list-sizes --location eastus -o table

# image types
az vm image list -o table
az vm image show --urn Canonical:UbuntuServer:16.04-LTS:latest

```