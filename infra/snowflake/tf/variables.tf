# ============================================================================
# Global Variables
# ============================================================================

variable "object_prefix" {
  description = "Prefix to add to all Snowflake object names (e.g., 'DEV' creates 'DEV_LOAD_WH')"
  type        = string
  default     = ""
}
variable "snowflake_private_key_path" {
  description = "Snowflake private key path"
  type        = string
  default     = "/Users/subhamaybhattacharyya/Projects/snowflake-lakehouse/infra/snowflake/tf/snowflake_tf_keys/snowflake_tf_key.p8"
}

# ============================================================================
# Snowflake Core Object Variables
# ============================================================================
# These variables are loaded from input-jsons/snowflake-core-objects.json
# via locals.tf and passed to the respective modules

# Warehouses Configuration
# Structure: Map of warehouse objects with the following properties:
# - name: Warehouse name (string)
# - comment: Description of warehouse purpose (string)
# - warehouse_size: Size of warehouse - X-SMALL, SMALL, MEDIUM, LARGE, etc. (string)
# - auto_resume: Auto-resume on query submission (bool)
# - auto_suspend: Seconds of inactivity before suspension (number)
# - enable_query_acceleration: Enable query acceleration (bool)
# - warehouse_type: STANDARD or SNOWPARK-OPTIMIZED (string)
# - min_cluster_count: Minimum clusters for multi-cluster warehouse (number)
# - max_cluster_count: Maximum clusters for multi-cluster warehouse (number)
# - scaling_policy: STANDARD or ECONOMY (string)
# - initially_suspended: Start warehouse in suspended state (bool)

# Databases Configuration
# Structure: Map of database objects with the following properties:
# - name: Database name (string)
# - comment: Description of database purpose (string)
# - schemas: List of schema objects, each containing:
#   - name: Schema name (string)
#   - comment: Description of schema purpose (string)
# - file_formats: Map of file format objects (optional), each containing:
#   - name: File format name (string)
#   - type: Format type - CSV, JSON, PARQUET, etc. (string)
#   - Additional format-specific properties

# ============================================================================
# Commented out - not used in current configuration
# variable "project_name" {
#   description = "Project name for resource naming"
#   type        = string
#   default     = "snw-lkh"
# }

# variable "environment" {
#   description = "Environment name (dev, staging, prod)"
#   type        = string
#   default     = "devl"

#   validation {
#     condition     = contains(["devl", "test", "prod"], var.environment)
#     error_message = "Environment must be devl, test, or prod."
#   }
# }

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



# ============================================================================
# AWS Variables
# ============================================================================

# Commented out - not used in current configuration
# variable "aws_region" {
#   description = "AWS region for resources"
#   type        = string
#   default     = "us-east-1"
# }
