This project had been built on top of [anandshivam44/tf-k8s-craftsman/tree/base](https://github.com/anandshivam44/tf-k8s-craftsman/tree/base) and Windsurf was used as an assistant to build the project especially helm charts

## Dependencies

- kubectl cli
- terraform cli
- aws cli
- helm cli
- packer cli

## How it works

1. Docker image is build using the Dockerfile in node-application
2. Packer is used to create a custom AMI for the EKS worker nodes here directory 00-packer
3. Terraform backend is created here directory 00-terraform-backend
4. EKS cluster is created here directory 01-eks-cluster
5. LoadBalancer Controller is created here directory 02-loadbalancer-controller-add-on
6. app helm charts are present here directory node-application

### Deploy
```bash
PROJECT_FOLDER=$(pwd)
```

### Docker build and push the image to dockerhub

Playbook here  [node-application/README.md](./node-application/README.md)

### Generate a Key Pair for Packer, Bastion Host and Managed Nodes, also upload it to aws

```bash
mkdir -p 01-eks-cluster/private-key
FILENAME=ec2_ssh_key
ssh-keygen -t ed25519 -a 100 -C $FILENAME -f ./01-eks-cluster/private-key/$FILENAME -N ''
aws ec2 import-key-pair --key-name $FILENAME --public-key-material fileb://./01-eks-cluster/private-key/$FILENAME.pub
```

### Build and create AMI using Packer

```bash
packer init 00.1-packer/al2023-eks-x86_64
packer validate 00.1-packer/al2023-eks-x86_64/al2023-eks-x86_64.pkr.hcl
packer build 00.1-packer/al2023-eks-x86_64/al2023-eks-x86_64.pkr.hcl
```

### Use terraform for creating dependencies for Terraform Backend (Quick Start Helper)

```bash
DIR=00-terraform-backend && terraform -chdir=$DIR init
DIR=00-terraform-backend && terraform -chdir=$DIR validate
DIR=00-terraform-backend && terraform -chdir=$DIR plan
DIR=00-terraform-backend && terraform -chdir=$DIR apply -auto-approve
```

### Replace all the terraform files in the entire directory with your own bucket name

```bash
BUCKET_NAME="$(terraform -chdir=00-terraform-backend output -raw s3_backend_bucket_name)"
echo $BUCKET_NAME
find "$PROJECT_FOLDER" -type f \( -name '*.tf' -o -name '*.tfvars' -o -name '*.tf.json' \) -exec sed -i "" -e 's/terraform-backend-placeholder/'"$BUCKET_NAME"'/g' {} + 
```

### Replace in the entire directory with your DynamoDB lock table name

```bash
DYNAMODB_TABLE="$(terraform -chdir=00-terraform-backend output -raw dynamodb_lock_table_name)"
echo $DYNAMODB_TABLE
find "$PROJECT_FOLDER" -type f \( -name '*.tf' -o -name '*.tfvars' -o -name '*.tf.json' \) -exec sed -i "" -e 's/dynamo-db-placeholder/'"$DYNAMODB_TABLE"'/g' {} +
```

### Create EKS, related Networking, related IAM Roles, OIDC and related Add-ons

```
DIR=01-eks-cluster && terraform -chdir=$DIR init
DIR=01-eks-cluster && terraform -chdir=$DIR validate
DIR=01-eks-cluster && terraform -chdir=$DIR plan
DIR=01-eks-cluster && terraform -chdir=$DIR apply -auto-approve
```

### SSH and Test Bastion Host

```bash
# Fetch Bastion IP from Terraform outputs
BASTION_IP="$(terraform -chdir=01-eks-cluster output -raw ec2_bastion_public_ip)"
echo "Bastion IP: $BASTION_IP"
chmod 400 ./01-eks-cluster/private-key/ec2_ssh_key
ssh -o StrictHostKeyChecking=no -i ./01-eks-cluster/private-key/ec2_ssh_key ec2-user@"$BASTION_IP"
```

### Copy private key to Bastion Host

```bash
scp -i 01-eks-cluster/private-key/ec2_ssh_key 01-eks-cluster/private-key/ec2_ssh_key ec2-user@$(terraform -chdir=01-eks-cluster output -raw ec2_bastion_public_ip):/home/ec2-user/
```

### Stop Bastion Host (Optional)

```bash
INSTANCE_ID="$(terraform -chdir=01-eks-cluster output -raw ec2_bastion_public_instance_ids)"
aws ec2 stop-instances --instance-ids $INSTANCE_ID
```

### Configure kubectl

```bash
aws eks --region us-east-1 update-kubeconfig --name infra-dev-innovation-hub --alias infra-dev-innovation-hub
```

### Use Ansible to check if NTP is installed and running on the worker nodes
modify ansible/inventory
```bash
ansible-playbook -i ansible/inventory check_ntp.yml
```

### Install LoadBalancer Controller Add-on

```
DIR=02-loadbalancer-controller-add-on && terraform -chdir=$DIR init
DIR=02-loadbalancer-controller-add-on && terraform -chdir=$DIR validate
DIR=02-loadbalancer-controller-add-on && terraform -chdir=$DIR plan
DIR=02-loadbalancer-controller-add-on && terraform -chdir=$DIR apply -auto-approve
```

### Add dockerhub auth to cluster

```bash
kubectl create secret docker-registry dockerhub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=<your-docker-username> \
  --docker-password=<your-docker-access-token> \
  --docker-email=<your-email>
```

### Deploy the helm application

[helm/README.md](./helm/README.md)

## Goals Achieved

### ✅ Dockerise https://github.com/swimlane/devops-practical

[node-application/README.md](./node-application/README.md)

### ✅ MongoDB should also be deployed as a docker container

[helm/templates/mongodb-deployment.yaml](./helm/templates/mongodb-deployment.yaml)

### ✅ Kubernetes cluster deployed via AWS EKS

- ✅ Uses Terraform to create the EKS cluster
- ✅ Uses Terraform to create initial K8s objects like LoadBalancer Controller Add-on

### ✅ Using Ansible to ensure NTP is installed and running on the worker nodes

### ✅ Access the app running in Kubernetes, register for an account, and add a record.

![App Screenshot](images/Screenshot%202025-09-07%20at%2012.59.58%E2%80%AFAM.png)

![App Screenshot 2](images/Screenshot%202025-09-07%20at%201.00.37%E2%80%AFAM.png)

❌ Packer Image is created but not used in EKS node group. This part was extremely time consuming that I had to give up for now to complete the task within a day. 

## App Security

1. ed25519 key pair for SSH keys everywhere
2. 3 tier network, 3 layer of subnets, Application launched in the 2nd tier in a private subnet. Exposed only via Load Balancer.
3. Worker node access via bAstion host only
4. Separate IAM roles for the EKS control plane and node groups.
5. The application Helm chart uses dedicated ServiceAccounts
6. **OIDC Integration for EKS:** An OIDC provider is configured for the cluster to enable IAM Roles for Service Accounts (IRSA). This allows pods to assume IAM roles with fine-grained permissions, eliminating the need for long-lived AWS credentials inside the cluster. Service accounts are annotated with an IAM role ARN, and pods automatically receive temporary, secure credentials from AWS STS.
7. Hardened Security Group rules for EKS cluster

## Scalability
1. Multi AZ Subnet for all 3 tier subnets
2. Configure the number of public worker nodes in the file: [01-eks-cluster/20-eks-node-group-public.tf](./01-eks-cluster/20-eks-node-group-public.tf) Set min=3, desired=3 and max=10 for hi~gh scalibility
3. Configure the number of private worker nodes in the file: [01-eks-cluster/20-eks-node-group-private.tf](./01-eks-cluster/20-eks-node-group-private.tf) Set min=3, desired=3 and max=10 for high scalibility
4. In Helm Set no of Replicas to 3 in the file: [helm/templates/deployment.yaml](./helm/templates/deployment.yaml)
5. Node groups allow auto-scaling in aws eks



### Cleaning Up
```bash
terraform -chdir=02-loadbalancer-controller-add-on plan -destroy -out destroy-plan.txt
terraform -chdir=02-loadbalancer-controller-add-on apply destroy-plan.txt

terraform -chdir=01-eks-cluster plan -destroy -out destroy-plan.txt
terraform -chdir=01-eks-cluster apply destroy-plan.txt

terraform -chdir=00-terraform-backend plan -destroy -out destroy-plan.txt
terraform -chdir=00-terraform-backend apply destroy-plan.txt

# packer cleanup
./scripts/delete_amis.sh

# Delete the SSH Public Key which was manually uploaded
aws ec2 delete-key-pair --key-name ec2_ssh_key
```

