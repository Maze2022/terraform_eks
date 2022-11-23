data "aws_instances" "worker_nodes" {
  instance_tags = {
    Name = "EKS-MANAGED-NODE"
  }
  instance_state_names = ["running"]
  depends_on = [module.eks.node_group_name]
}