# ============================================================================
# Azure Infrastructure Variables
# ============================================================================

variable "azure_region" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
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

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
