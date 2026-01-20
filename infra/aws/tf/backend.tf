# --- root/aws/tf/root/backend.tf ---

terraform {
  required_version = ">= 1.14.1"

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

  cloud {
    organization = "subhamay-bhattacharyya-projects"

    workspaces {
      name = "snowflake-datalake-aws"
    }
  }
}