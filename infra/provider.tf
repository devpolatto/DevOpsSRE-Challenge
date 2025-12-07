terraform {
  backend "azurerm" {
    key              = "DevOpsSRE-Challenge"
    use_azuread_auth = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31.0, < 6.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.22.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = var.aws_config.profile
  #   assume_role {
  #     role_arn = local.aws_env.iam_role.terraformRole
  #   }
  region = var.aws_config.region
  #   default_tags {
  #     tags = local.common_tags
  #   }
}

provider "azurerm" {
  subscription_id = local.azure_env.account.subscription
  features {}
}

provider "azuread" {
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
