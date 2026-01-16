# ============================================================================
# GCP Infrastructure Variables
# ============================================================================

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "snowflake-lakehouse"
}

variable "kms_key_name" {
  description = "KMS key name for bucket encryption (optional)"
  type        = string
  default     = null
}

variable "labels" {
  description = "Additional labels for resources"
  type        = map(string)
  default     = {}
}
