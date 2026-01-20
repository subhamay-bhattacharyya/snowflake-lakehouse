# --- Snowflake Stage Outputs ---

output "name" {
  description = "Name of the stage"
  value       = snowflake_stage.this.name
}

output "id" {
  description = "ID of the stage"
  value       = snowflake_stage.this.id
}

output "fully_qualified_name" {
  description = "Fully qualified name of the stage"
  value       = "${var.database}.${var.schema}.${snowflake_stage.this.name}"
}
