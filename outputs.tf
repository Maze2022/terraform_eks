#---------- root/outputs.tf

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "worker_nodes" {
  value = {for i in range(length(data.aws_instances.worker_nodes.ids)) : data.aws_instances.worker_nodes.ids[i] => data.aws_instances.worker_nodes.private_ips[i] }
}