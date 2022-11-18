#---------- eks/variables.tf

variable "vpc_id" {}

variable "endpoint_public_access" {}

variable "endpoint_private_access" {}

variable "public_subnets" {}

variable "desired_size" {
    type = number
}
variable "max_size" {
    type = number
}

variable "min_size" {
    type = number
}

