# --- Snowflake Parent Module Outputs ---

output "warehouses" {
  description = "Map of warehouse names to their details"
  value = {
    for k, v in module.warehouse : k => {
      name = v.name
      id   = v.id
    }
  }
}

# output "databases" {
#   description = "Map of database names to their details"
#   value = {
#     for k, v in module.database : k => {
#       name    = v.name
#       id      = v.id
#       schemas = v.schemas
#     }
#   }
# }

# output "storage_integrations" {
#   description = "Map of storage integration names to their details"
#   value = {
#     for k, v in module.storage_integration : k => {
#       name                      = v.name
#       id                        = v.id
#       storage_aws_iam_user_arn  = v.storage_aws_iam_user_arn
#       storage_aws_external_id   = v.storage_aws_external_id
#     }
#   }
# }

# output "stages" {
#   description = "Map of stage names to their details"
#   value = {
#     for k, v in module.stage : k => {
#       name                  = v.name
#       id                    = v.id
#       fully_qualified_name  = v.fully_qualified_name
#     }
#   }
# }

# output "pipes" {
#   description = "Map of pipe names to their details"
#   value = {
#     for k, v in module.pipe : k => {
#       name                 = v.name
#       id                   = v.id
#       notification_channel = v.notification_channel
#     }
#   }
# }
