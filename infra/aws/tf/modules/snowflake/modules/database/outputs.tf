# --- Snowflake Database Outputs ---

output "name" {
  description = "Name of the database"
  value       = snowflake_database.this.name
}

output "id" {
  description = "ID of the database"
  value       = snowflake_database.this.id
}

output "schemas" {
  description = "Map of schema names to their IDs"
  value       = { for k, v in snowflake_schema.schemas : k => v.id }
}
