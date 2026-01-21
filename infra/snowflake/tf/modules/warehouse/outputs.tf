# ============================================================================
# Snowflake Warehouse Outputs
# ============================================================================

output "warehouses" {
  description = "Map of warehouse names to their details"
  value = {
    for k, v in snowflake_warehouse.this : k => {
      name = v.name
      id   = v.id
    }
  }
}
