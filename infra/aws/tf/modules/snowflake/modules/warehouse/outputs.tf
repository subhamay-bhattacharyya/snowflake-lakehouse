# --- Snowflake Warehouse Outputs ---

output "name" {
  description = "Name of the warehouse"
  value       = snowflake_warehouse.this.name
}

output "id" {
  description = "ID of the warehouse"
  value       = snowflake_warehouse.this.id
}
