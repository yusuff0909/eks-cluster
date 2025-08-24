# provision-eks-cluster-with-terraform
This repository helps you provision a cluster in AWS EKS using Terraform

## Features

This Terraform configuration provisions:

- **EKS Cluster** with managed node groups
- **VPC** with public and private subnets
- **Security Groups** for cluster and nodes
- **EBS CSI Driver** for persistent storage
- **EFS CSI Driver** for shared file storage via Helm
- **ArgoCD** for GitOps continuous deployment via Helm
- **Sample EFS File System** for shared storage

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.2.0
- kubectl
- helm (optional, for manual operations)

## Usage

1. Clone this repository
2. Update `variables.tf` with your desired values
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Plan the deployment:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Post-Deployment

### Connect to the cluster:
```bash
aws eks update-kubeconfig --region <your-region> --name <cluster-name>
```

### Access ArgoCD:
1. Get the ArgoCD server URL from Terraform outputs
2. Get the admin password:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
   ```
3. Login with username `admin` and the retrieved password

### Using EFS:
The EFS file system ID and DNS name are available in Terraform outputs. You can use these to create PersistentVolumes in Kubernetes.

## Components Installed

- **ArgoCD**: GitOps continuous deployment tool
- **EFS CSI Driver**: Enables dynamic provisioning of EFS volumes
- **EBS CSI Driver**: Enables dynamic provisioning of EBS volumes

## Clean Up

To destroy all resources:
```bash
terraform destroy
```
