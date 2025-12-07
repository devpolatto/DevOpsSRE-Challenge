module "sharedvariables" {
  source = "git::ssh://git@polattoxcodelearning/v3/polattoxcodelearning/Lab/TerraformModules//shared-variables?ref=main"
}

locals {
  azure_env = module.sharedvariables.envs["global"].azure
  aws_env   = module.sharedvariables.envs[var.environment]

  aws_region = module.sharedvariables.aws_regions[var.aws_config.region]

  aws_prefix_name = "${var.environment}-${local.aws_region}-SREChallenge"
}

variable "environment" {
  type = string
}

variable "aws_config" {
  type = object({
    profile = string
    region  = string
  })
  default = {
    profile = "dev"
    region  = "us-east-1"
  }
}