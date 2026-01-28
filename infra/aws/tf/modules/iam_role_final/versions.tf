# -- infra/aws/tf/modules/iam_role_final/versions.tf (Child Module)
# ============================================================================
# IAM Role Trust Policy Update Module - Provider Requirements
# ============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
