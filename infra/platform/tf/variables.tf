# -- infra/platform/tf/variables.tf (Platform Module)
# ============================================================================
# Platform Module Variables
# ============================================================================

variable "environment" {
  description = "Environment name (devl, test, prod)"
  type        = string
  default     = "devl"

  validation {
    condition     = contains(["devl", "test", "prod"], var.environment)
    error_message = "Environment must be devl, test, or prod."
  }
}

variable "project_code" {
  description = "Project code prefix for resource naming (e.g., snw-lkh)"
  type        = string
  default     = "snw"
}

# ============================================================================
# Snowflake Provider Variables
# ============================================================================

variable "snowflake_organization_name" {
  description = "Snowflake organization name"
  type        = string
  default     = ""
}

variable "snowflake_account_name" {
  description = "Snowflake account name"
  type        = string
  default     = ""
}

variable "snowflake_user" {
  description = "Snowflake user for Terraform operations"
  type        = string
  default     = ""
}

variable "snowflake_role" {
  description = "Snowflake role for Terraform operations"
  type        = string
  default     = "SYSADMIN"
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse for Terraform operations"
  type        = string
  default     = "COMPUTE_WH"
}

variable "snowflake_private_key_path" {
  description = "Path to Snowflake private key file for JWT authentication"
  type        = string
  default     = ""
}

# ============================================================================
# AWS Configuration Object
# ============================================================================

variable "aws_config" {
  description = "AWS infrastructure configuration - pass via JSON file"
  type = object({
    region = optional(string, "us-east-1")
    s3 = optional(object({
      bucket_name   = string
      versioning    = optional(bool, true)
      kms_key_alias = optional(string, "alias/aws/s3")
    }))
    iam = optional(object({
      role_name = optional(string, "snowflake-external-stage-role")
    }))
    trust = optional(object({
      snowflake_principal_arn = optional(string, "")
      snowflake_external_id   = optional(string, "")
    }))
  })
  default = {}
}

# ============================================================================
# Snowflake Configuration Object
# ============================================================================

variable "snowflake_config" {
  description = "Snowflake infrastructure configuration - pass via JSON file"
  type = object({
    warehouses   = optional(list(any), [])
    databases    = optional(list(any), [])
    file_formats = optional(list(any), [])
    storage_integrations = optional(list(object({
      name                      = string
      type                      = optional(string, "EXTERNAL_STAGE")
      storage_provider          = string
      storage_aws_role_arn      = optional(string)
      storage_allowed_locations = list(string)
      enabled                   = optional(bool, true)
      comment                   = optional(string, "")
    })), [])
    stages    = optional(list(any), [])
    snowpipes = optional(list(any), [])
  })
  default = {}
}
