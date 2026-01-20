# ============================================================================
# Snowflake Core Module Variables
# ============================================================================

variable "warehouses" {
  description = "Map of warehouses to create"
  type = map(object({
    name                      = string
    warehouse_size            = optional(string, "X-SMALL")
    auto_suspend              = optional(number, 60)
    auto_resume               = optional(bool, true)
    warehouse_type            = optional(string, "STANDARD")
    comment                   = optional(string, "")
    enable_query_acceleration = optional(bool, false)
    min_cluster_count         = optional(number, 1)
    max_cluster_count         = optional(number, 1)
    scaling_policy            = optional(string, "STANDARD")
    initially_suspended       = optional(bool, true)
  }))
  default = {}
}

variable "databases" {
  description = "Map of databases to create with their schemas"
  type = map(object({
    name    = string
    comment = optional(string, "")
    schemas = optional(list(object({
      name    = string
      comment = optional(string, "")
    })), [])
  }))
  default = {}
}
