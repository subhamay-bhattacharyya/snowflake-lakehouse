# --- Snowflake Parent Module Variables ---

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

# variable "databases" {
#   description = "Map of databases to create with their schemas"
#   type = map(object({
#     name    = string
#     comment = optional(string, "")
#     schemas = optional(list(object({
#       name    = string
#       comment = optional(string, "")
#     })), [])
#   }))
#   default = {}
# }

# variable "storage_integrations" {
#   description = "Map of storage integrations to create"
#   type = map(object({
#     name                       = string
#     comment                    = optional(string, "")
#     enabled                    = optional(bool, true)
#     storage_provider           = optional(string, "S3")
#     storage_allowed_locations  = list(string)
#     storage_blocked_locations  = optional(list(string), [])
#     storage_aws_role_arn       = optional(string)
#     storage_aws_object_acl     = optional(string, "bucket-owner-full-control")
#   }))
#   default = {}
# }

# variable "stages" {
#   description = "Map of stages to create"
#   type = map(object({
#     name                     = string
#     database                 = string
#     schema                   = string
#     url                      = string
#     storage_integration_name = string
#     file_format              = optional(string)
#     comment                  = optional(string, "")
#   }))
#   default = {}
# }

# variable "pipes" {
#   description = "Map of pipes to create"
#   type = map(object({
#     name           = string
#     database       = string
#     schema         = string
#     copy_statement = string
#     auto_ingest    = optional(bool, true)
#     comment        = optional(string, "")
#   }))
#   default = {}
# }
