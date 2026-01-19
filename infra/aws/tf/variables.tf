# ============================================================================
# AWS Infrastructure Variables
# ============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
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
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "snw-lkh"
}
variable "snowflake_external_id" {
  description = "Snowflake external ID for IAM role trust relationship"
  type        = string
  sensitive   = true
  default     = ""
}
variable "snowflake_principal_arn" {
  description = "Snowflake principal ARN for IAM role trust relationship"
  type        = string
  default     = ""
}
# variable "enable_s3_notifications" {
#   description = "Enable S3 event notifications for Snowpipe"
#   type        = bool
#   default     = false
# }

# variable "raw_data_lifecycle_days" {
#   description = "Number of days to retain raw data before transitioning to Glacier"
#   type        = number
#   default     = 90
# }

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
