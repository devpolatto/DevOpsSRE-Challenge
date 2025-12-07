locals {
  subnets                  = cidrsubnets(var.vpc.cidr_block, 4)
  cdir_broken_two_networks = cidrsubnets(var.vpc.cidr_block, 1, 1)

  public_subnets_cidr  = cidrsubnets("${local.cdir_broken_two_networks[0]}", 2, 2, 2)
  private_subnets_cidr = cidrsubnets("${local.cdir_broken_two_networks[1]}", 2, 2, 2)
}

variable "availability_zones" {
  description = "AZs da região"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc" {
  type = object({
    name       = string
    cidr_block = string
  })
}

variable "aws_internet_gateway" {
  type = object({
    enabled = bool
  })
  default = {
    enabled = true
  }
}

variable "tags" {
  type = map(string)
}