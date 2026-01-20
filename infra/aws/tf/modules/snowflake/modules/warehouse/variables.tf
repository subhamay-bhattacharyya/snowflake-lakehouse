# --- Snowflake Warehouse Variables ---

variable "name" {
  description = "Name of the warehouse"
  type        = string
}

variable "warehouse_size" {
  description = "Size of the warehouse (X-SMALL, SMALL, MEDIUM, LARGE, X-LARGE, etc.)"
  type        = string
  default     = "X-SMALL"
}

variable "auto_suspend" {
  description = "Number of seconds of inactivity before warehouse is suspended"
  type        = number
  default     = 60
}

variable "auto_resume" {
  description = "Whether to automatically resume the warehouse when a query is submitted"
  type        = bool
  default     = true
}

variable "warehouse_type" {
  description = "Type of warehouse (STANDARD or SNOWPARK-OPTIMIZED)"
  type        = string
  default     = "STANDARD"
}

variable "comment" {
  description = "Comment for the warehouse"
  type        = string
  default     = ""
}

variable "enable_query_acceleration" {
  description = "Whether to enable query acceleration for the warehouse"
  type        = bool
  default     = false
}

variable "min_cluster_count" {
  description = "Minimum number of clusters for multi-cluster warehouse"
  type        = number
  default     = 1
}

variable "max_cluster_count" {
  description = "Maximum number of clusters for multi-cluster warehouse"
  type        = number
  default     = 1
}

variable "scaling_policy" {
  description = "Scaling policy for multi-cluster warehouse (STANDARD or ECONOMY)"
  type        = string
  default     = "STANDARD"
}

variable "initially_suspended" {
  description = "Whether the warehouse should be initially suspended"
  type        = bool
  default     = true
}
