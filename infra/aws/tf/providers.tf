# --- root/aws/tf/root/providers.tf ---

terraform {
  required_version = ">= 1.14.1" # Adjust as needed for your environment

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 1.12.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.94"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
}

# Configure the Snowflake Provider
provider "snowflake" {
  account     = var.snowflake_account
  user        = var.snowflake_user
  password    = var.snowflake_password != "" ? var.snowflake_password : null
  private_key = var.snowflake_private_key != "" ? var.snowflake_private_key : null
  role        = var.snowflake_role
}