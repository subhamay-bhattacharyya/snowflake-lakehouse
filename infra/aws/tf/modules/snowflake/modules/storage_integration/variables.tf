# --- Snowflake Storage Integration Variables ---

variable "name" {
  description = "Name of the storage integration"
  type        = string
}

variable "comment" {
  description = "Comment for the storage integration"
  type        = string
  default     = ""
}

variable "enabled" {
  description = "Whether the storage integration is enabled"
  type        = bool
  default     = true
}

variable "storage_provider" {
  description = "Storage provider (S3, GCS, or AZURE)"
  type        = string
  default     = "S3"
}

variable "storage_allowed_locations" {
  description = "List of allowed storage locations"
  type        = list(string)
}

variable "storage_blocked_locations" {
  description = "List of blocked storage locations"
  type        = list(string)
  default     = []
}

variable "storage_aws_role_arn" {
  description = "ARN of the AWS IAM role for S3 access"
  type        = string
  default     = null
}

variable "storage_aws_object_acl" {
  description = "AWS object ACL for S3"
  type        = string
  default     = "bucket-owner-full-control"
}
