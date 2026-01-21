# ============================================================================
# Root Module Outputs
# ============================================================================

output "warehouses" {
  description = "Map of warehouse names to their details"
  value = {
    for k, v in module.warehouses.warehouses : k => {
      warehouse_type            = v.warehouse_type
      warehouse_size            = v.warehouse_size
      comment                   = v.comment
      auto_suspend              = v.auto_suspend
      auto_resume               = v.auto_resume
      initially_suspended       = v.initially_suspended
      enable_query_acceleration = v.enable_query_acceleration
      warehouse_type            = v.warehouse_type
      min_cluster_count         = v.min_cluster_count
      max_cluster_count         = v.max_cluster_count
    }
  }
}

output "databases" {
  description = "Map of databases names to their details"
  value       = module.databases.databases
}

# output "databases_json" {
#   description = "Databases output in JSON format"
#   value       = jsonencode(module.databases.databases)
# }


output "schemas" {
  description = "Map of databases schemas to their details"
  value       = module.databases.schemas
}

output "file_formats" {
  description = "Map of file formats to their details"
  value       = module.file_formats.file_formats
}

# output "storage_integration_names" {
#   description = "Storage integration names"
#   value       = module.storage_integrations.storage_integrations
# }

output "local_storage_integrations" {
  description = "Storage integrations"
  value       = local.storage_integrations
}