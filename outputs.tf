output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "connect-to-cluser" {
  description = "command to connect to cluster"
  value = "aws eks update-kubeconfig --region ${var.region} --name ${local.cluster_name}"
}

# ArgoCD outputs
output "argocd_server_url" {
  description = "ArgoCD server URL (LoadBalancer endpoint)"
  value       = "http://${helm_release.argocd.status[0].load_balancer[0].ingress[0].hostname}"
  depends_on  = [helm_release.argocd]
}

output "argocd_admin_password_command" {
  description = "Command to get ArgoCD admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

# EFS outputs
output "efs_file_system_id" {
  description = "EFS file system ID"
  value       = aws_efs_file_system.example.id
}

output "efs_dns_name" {
  description = "EFS DNS name"
  value       = aws_efs_file_system.example.dns_name
}
