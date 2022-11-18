# ---------vpc/variables.tf

variable "vpc_cidr" {
  type = string
}

variable "public_cidrs" {
  type = list(any)
}

variable "public_sn_count" {
  type = number
}

variable "map_public_ip_on_launch" {
  type = string
}