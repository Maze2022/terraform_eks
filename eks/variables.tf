#---------- eks/variables.tf

variable "vpc_id" {}

variable "endpoint_public_access" {}

variable "endpoint_private_access" {}

variable "public_subnets" {}

variable "key_pair" {}

variable "instance_types" {}

variable "node_group_name" {}

variable "public_access_cidrs" {}

variable "desired_size" {
  type = number
}
variable "max_size" {
  type = number
}

variable "min_size" {
  type = number
}

