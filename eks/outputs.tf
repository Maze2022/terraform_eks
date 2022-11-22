# -------- eks/outputs.tf

output "cluster_id" {
  value = aws_eks_cluster.luit_cluster.id
}

output "cluster_name" {
  value = aws_eks_cluster.luit_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.luit_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.luit_cluster.certificate_authority[0].data
}