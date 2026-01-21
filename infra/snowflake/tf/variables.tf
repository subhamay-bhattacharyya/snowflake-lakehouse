# ============================================================================
# Global Variables
# ============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "snw-lkh"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "devl"

  validation {
    condition     = contains(["devl", "test", "prod"], var.environment)
    error_message = "Environment must be devl, test, or prod."
  }
}

# variable "tags" {
#   description = "Common tags for all resources"
#   type        = map(string)
#   default     = {}
# }

# ============================================================================
# Cloud Provider Enablement
# ============================================================================

# variable "enable_aws" {
#   description = "Enable AWS resources (S3, IAM)"
#   type        = bool
#   default     = true
# }

# variable "enable_gcp" {
#   description = "Enable GCP resources (GCS, Service Account)"
#   type        = bool
#   default     = false
# }

# variable "enable_azure" {
#   description = "Enable Azure resources (Blob Storage, Managed Identity)"
#   type        = bool
#   default     = false
# }

# ============================================================================
# Snowflake Variables
# ============================================================================

#variable "snowflake_account" {
#  description = "Snowflake account identifier"
#  type        = string
#  default     = ""
#}

#variable "snowflake_user" {
#  description = "Snowflake user for Terraform operations"
#  type        = string
#  default     = ""
#}

#variable "snowflake_password" {
#  description = "Snowflake password (use either password or private_key)"
#  type        = string
#  sensitive   = true
#  default     = ""
#}

#variable "snowflake_private_key" {
#  description = "Snowflake private key for key-pair authentication"
#  type        = string
#  sensitive   = true
#  default     = ""
#}

#variable "snowflake_role" {
#  description = "Snowflake role for Terraform operations"
#  type        = string
#  default     = "SYSADMIN"
#}

# ============================================================================
# AWS Variables
# ============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# ============================================================================
# GCP Variables
# ============================================================================

variable "gcp_project" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

# ============================================================================
# Azure Variables
# ============================================================================

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = ""
}

variable "azure_location" {
  description = "Azure location for resources"
  type        = string
  default     = "eastus"
}
