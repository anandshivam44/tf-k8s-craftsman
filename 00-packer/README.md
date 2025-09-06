# Packer AMI Builds for EKS Cluster

This directory contains Packer templates to build custom Amazon Machine Images (AMIs) for the EKS worker nodes used in this project.

## AMIs

### 1. EKS-Optimized Amazon Linux 2023 (ARM64)

- **Template**: `al2023-eks-x86_64/al2023-eks-x86_64.pkr.hcl`
- **Architecture**: `arm64`
- **Base AMI**: Official EKS-optimized Amazon Linux 2023 for Kubernetes v1.32.
- **Customization**: Installs and enables `chrony` for Network Time Protocol (NTP) synchronization, which is crucial for Kubernetes cluster stability.

## Prerequisites

1.  **Packer**: Ensure you have [Packer](https://www.packer.io/downloads) installed.
2.  **AWS Credentials**: Configure your AWS credentials. The build process requires permissions to create EC2 instances, manage AMIs, and read from SSM Parameter Store.
3.  **SSH Key**: An EC2 key pair named `ec2_ssh_key` must exist in the target region. The private key should be available at `01-eks-cluster/private-key/ec2_ssh_key` relative to the root of the repository.

## How to Build

1.  Navigate to the specific AMI directory:
    ```sh
    cd 00-packer/al2023-eks-x86_64
    ```

2.  Initialize Packer to download the required plugins:
    ```sh
    packer init .
    ```

3.  Validate the template (optional):
    ```sh
    packer validate .
    ```

4.  Build the AMI:
    ```sh
    packer build .
    ```

Upon successful completion, Packer will output the ID of the newly created AMI. This ID is then used in the Terraform configuration for the EKS cluster's launch template.

### Variables

The build can be customized by overriding the default variables. For example, to build in a different region:

```sh
packer build -var 'region=us-west-2' .
```

Key variables are defined in the `.pkr.hcl` file and include:
- `region`: The AWS region for the build.
- `instance_type`: The EC2 instance type for the build.
- `kubernetes_version`: The target Kubernetes version for the base AMI.
