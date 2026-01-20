# --- Snowflake Parent Module ---
# This module orchestrates all Snowflake resources using nested sub-modules

# Warehouse Module
module "warehouse" {
  source = "./modules/warehouse"

  for_each = var.warehouses

  name                      = each.value.name
  warehouse_size            = lookup(each.value, "warehouse_size", "X-SMALL")
  auto_suspend              = lookup(each.value, "auto_suspend", 60)
  auto_resume               = lookup(each.value, "auto_resume", true)
  warehouse_type            = lookup(each.value, "warehouse_type", "STANDARD")
  comment                   = lookup(each.value, "comment", "")
  enable_query_acceleration = lookup(each.value, "enable_query_acceleration", false)
  min_cluster_count         = lookup(each.value, "min_cluster_count", 1)
  max_cluster_count         = lookup(each.value, "max_cluster_count", 1)
  scaling_policy            = lookup(each.value, "scaling_policy", "STANDARD")
  initially_suspended       = lookup(each.value, "initially_suspended", true)
}

# # Database Module (with schemas)
# module "database" {
#   source = "./modules/database"
#
#   for_each = var.databases
#
#   name    = each.value.name
#   comment = lookup(each.value, "comment", "")
#   schemas = lookup(each.value, "schemas", [])
# }

# # Storage Integration Module
# module "storage_integration" {
#   source = "./modules/storage_integration"
#
#   for_each = var.storage_integrations
#
#   name                       = each.value.name
#   comment                    = lookup(each.value, "comment", "")
#   enabled                    = lookup(each.value, "enabled", true)
#   storage_provider           = lookup(each.value, "storage_provider", "S3")
#   storage_allowed_locations  = each.value.storage_allowed_locations
#   storage_blocked_locations  = lookup(each.value, "storage_blocked_locations", [])
#   storage_aws_role_arn       = lookup(each.value, "storage_aws_role_arn", null)
#   storage_aws_object_acl     = lookup(each.value, "storage_aws_object_acl", "bucket-owner-full-control")
# }

# # Stage Module
# module "stage" {
#   source = "./modules/stage"
#
#   for_each = var.stages
#
#   name                      = each.value.name
#   database                  = each.value.database
#   schema                    = each.value.schema
#   url                       = each.value.url
#   storage_integration_name  = each.value.storage_integration_name
#   file_format               = lookup(each.value, "file_format", null)
#   comment                   = lookup(each.value, "comment", "")
#
#   depends_on = [module.storage_integration, module.database]
# }

# # Pipe Module
# module "pipe" {
#   source = "./modules/pipe"
#
#   for_each = var.pipes
#
#   name           = each.value.name
#   database       = each.value.database
#   schema         = each.value.schema
#   copy_statement = each.value.copy_statement
#   auto_ingest    = lookup(each.value, "auto_ingest", true)
#   comment        = lookup(each.value, "comment", "")
#
#   depends_on = [module.stage, module.database]
# }
