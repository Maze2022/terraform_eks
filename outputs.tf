#---------- root/outputs.tf

output "cluster_name" {
    value = aws_eks_cluster.wk22_cluster.name
}

output "cluster_endpoint" {
    value = 
}
