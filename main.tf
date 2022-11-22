# -------- root/main.tf

module "vpc" {
  source                  = "./vpc"
  vpc_cidr                = "192.168.0.0/16"
  public_sn_count         = 2
  access_ip               = var.access_ip
  public_cidrs            = [for i in range(1, 4, 2) : cidrsubnet("192.168.0.0/16", 8, i)]
  map_public_ip_on_launch = true
}

module "eks" {
  source                  = "./eks"
  vpc_id                  = module.vpc.vpc_id
  public_subnets          = module.vpc.public_subnets
  instance_types          = ["t3.small"]
  node_group_name         = "worker_nodes"
  public_access_cidrs     = ["0.0.0.0/0"]
  desired_size            = 2
  max_size                = 3
  min_size                = 1
  endpoint_public_access  = true
  endpoint_private_access = false
  key_pair                = "MazeKeys"
}