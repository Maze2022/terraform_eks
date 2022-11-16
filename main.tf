# -------- root/main.tf

module "vpc" {
  source               = "./vpc"
  vpc_cidr             = "192.168.0.0/16"
  public_sn_count      = 2
  public_cidrs         = [for i in range(1, 3, 1) : cidrsubnet("192.168.0.0/16", 8, i)]
}

