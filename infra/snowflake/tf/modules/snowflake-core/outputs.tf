# ============================================================================
# Snowflake Core Module Outputs
# ============================================================================

output "warehouses" {
  description = "Map of warehouse details"
  value = {
    for k, v in module.warehouse : k => {
      name = v.name
      id   = v.id
    }
  }
}

output "databases" {
  description = "Map of database details with schemas"
  value = {
    for k, v in module.database : k => {
      name    = v.name
      id      = v.id
      schemas = v.schemas
    }
  }
}
