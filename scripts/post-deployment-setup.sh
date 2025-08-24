#!/bin/bash

# Post-deployment setup script for EKS cluster with ArgoCD and EFS

set -e

echo "🚀 EKS Cluster Post-Deployment Setup"
echo "===================================="

# Get cluster name from Terraform output
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region)
EFS_ID=$(terraform output -raw efs_file_system_id)

echo "📋 Cluster Information:"
echo "  - Cluster Name: $CLUSTER_NAME"
echo "  - Region: $REGION"
echo "  - EFS ID: $EFS_ID"

# Update kubeconfig
echo ""
echo "🔧 Updating kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Wait for ArgoCD to be ready
echo ""
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD admin password
echo ""
echo "🔑 ArgoCD Admin Credentials:"
echo "  - Username: admin"
echo -n "  - Password: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
echo ""

# Get ArgoCD URL
echo ""
echo "🌐 ArgoCD Access Information:"
ARGOCD_URL=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
if [ -n "$ARGOCD_URL" ]; then
    echo "  - ArgoCD URL: http://$ARGOCD_URL"
else
    echo "  - ArgoCD URL: Waiting for LoadBalancer to assign hostname..."
    echo "    Run 'kubectl get svc argocd-server -n argocd' to check status"
fi

# Create EFS StorageClass with the actual EFS ID
echo ""
echo "📁 Creating EFS StorageClass..."
cat > /tmp/efs-storageclass.yaml << EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: $EFS_ID
  directoryPerms: "0755"
EOF

kubectl apply -f /tmp/efs-storageclass.yaml
rm /tmp/efs-storageclass.yaml

echo ""
echo "✅ Setup Complete!"
echo ""
echo "📝 Next Steps:"
echo "  1. Access ArgoCD at the URL above"
echo "  2. Login with username 'admin' and the password shown above"
echo "  3. Use the 'efs-sc' StorageClass for EFS volumes"
echo "  4. Check examples/efs-example.yaml for EFS usage sample"
echo ""
echo "🔍 Useful Commands:"
echo "  - Get pods: kubectl get pods -A"
echo "  - Check ArgoCD: kubectl get all -n argocd"
echo "  - Check EFS CSI: kubectl get pods -n kube-system | grep efs"
