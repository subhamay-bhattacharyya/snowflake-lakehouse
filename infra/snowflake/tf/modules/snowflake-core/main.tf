# ============================================================================
# Snowflake Core Resources Module
# ============================================================================
# This module creates cloud-agnostic Snowflake resources:
# - Warehouses
# - Databases
# - Schemas
# ============================================================================

# ----------------------------------------------------------------------------
# Warehouses
# ----------------------------------------------------------------------------

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

# ----------------------------------------------------------------------------
# Databases with Schemas
# ----------------------------------------------------------------------------

module "database" {
  source = "./modules/database"

  for_each = var.databases

  name    = each.value.name
  comment = lookup(each.value, "comment", "")
  schemas = lookup(each.value, "schemas", [])
}
