#!/bin/bash

# This script updates the Ansible inventory file with the public IP of the bastion host
# and the private IPs of the EKS worker nodes.

# Set the path to the inventory file
INVENTORY_FILE="/Users/shivam.anand/personal/swim/tf-k8s-craftsman/ansible/inventory.ini"

# Get the bastion's public IP from Terraform output
BASTION_IP=$(terraform -chdir="/Users/shivam.anand/personal/swim/tf-k8s-craftsman/01-eks-cluster" output -raw ec2_bastion_public_ip)

# Get the EKS cluster name from terraform output
CLUSTER_NAME=$(terraform -chdir="/Users/shivam.anand/personal/swim/tf-k8s-craftsman/01-eks-cluster" output -raw eks_cluster_name)
echo "Cluster name: $CLUSTER_NAME"

# Get the private IPs of the worker nodes
WORKER_IPS=$(aws ec2 describe-instances --filters \
    "Name=tag:eks:cluster-name,Values=$CLUSTER_NAME" \
    "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].PrivateIpAddress' \
    --output text)

if [ -z "$WORKER_IPS" ]; then
    echo "Error: Could not retrieve worker node IPs. Make sure your EKS cluster is running."
    exit 1
fi

# Update the bastion IP in the inventory file
sed -i.bak "s/<bastion_public_ip>/$BASTION_IP/g" "$INVENTORY_FILE"

# Clear existing worker nodes
sed -i.bak '/^worker[0-9]/d' "$INVENTORY_FILE"

# Add the new worker nodes to the inventory file
COUNT=1
for IP in $WORKER_IPS; do
    echo "worker$COUNT ansible_host=$IP" >> "$INVENTORY_FILE"
    COUNT=$((COUNT+1))
done

echo "Inventory file '$INVENTORY_FILE' updated successfully."
