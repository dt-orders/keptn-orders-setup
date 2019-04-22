# AWS bastion host VM

Below are instructions for using the aws CLI to provison an ubuntu virtual machine on Google to use for the cluster, keptn, and application setup. 

Recommended image is:
* Ubuntu Server 16.04 LTS (HVM), SSD Volume Type - ami-08692d171e3cf02d6 (64-bit x86) / ami-05e1b2aec3b47890f (64-bit Arm)
* Ubuntu Server 16.04 LTS (HVM),EBS General Purpose (SSD) Volume Type. Support available from Canonical (http://www.ubuntu.com/cloud/services).

You can also make the VM from the console, and the continue with the steps to connect using ssh.

# Create instance using aws cli

Run this command to create the VM.  You need to adjust value for ssh key name.  You can optionally adjust values for tags and region.  [aws docs](https://docs.aws.amazon.com/cli/latest/reference/ec2/run-instances.html)


```
aws ec2 run-instances \
  --image-id ami-08692d171e3cf02d6 \
  --count 1 \
  --instance-type t2.micro \
  --key-name jahn-dt-aws  \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=keptn-bastion}]' \
  --region us-west-2
```

--security-group-ids sg-af7a50c8 --subnet-id subnet-3b839262

# SSH into the VM 

From the aws web console, get the connection string for the VM. Run this command to SSH to the new VM.
```
ssh -i "<your pem file>.pem" ubuntu@<your host>.compute.amazonaws.com
```

# Initialize aws cli

Within the VM, run this command to install the aws CLI ```sudo apt install awscli```

Run this command to configure the cli ```aws configure```

At the prompt, 
* enter your AWS Access Key ID
* enter your AWS Secret Access Key ID
* enter Default region name example us-east-1
* enter Default output format, enter json

See [this article](https://aws.amazon.com/blogs/security/wheres-my-secret-access-key/) for For help access keys

When complete, run this command ```aws ec2 describe-instances``` to see your VMs

# Clone the Orders setup repo

Within the VM, run these commands to clone the setup repo.

```
git clone https://github.com/keptn-orders/keptn-orders-setup.git

cd keptn-orders-setup
```

Now proceed to the [Installation script for ubuntu](README.md#installation-script-for-ubuntu) step and then the 'Provision Cluster, Install Keptn, and onboard the Orders application' steps.

# Delete the VM

The the aws web console, choose VM and terminate it.
