# -- infra/platform/tf/backend.tf (Platform Module)
# ============================================================================
# Terraform Backend Configuration
# ============================================================================

terraform {
  required_version = ">= 1.14.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 0.98"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }

  cloud {
    organization = "subhamay-bhattacharyya-projects"

    workspaces {
      name = "snowflake-datalake-aws"
    }
  }
}
