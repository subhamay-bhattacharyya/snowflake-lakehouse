# ============================================================================
# Snowflake Database Variables
# ============================================================================

variable "databases" {
  description = "List of database configurations as JSON objects"
  type = list(object({
    name    = string
    comment = optional(string, "")
    schemas = optional(list(object({
      name    = string
      comment = optional(string, "")
    })), [])
  }))
}