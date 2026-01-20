# --- Snowflake Storage Integration Outputs ---

output "name" {
  description = "Name of the storage integration"
  value       = snowflake_storage_integration.this.name
}

output "id" {
  description = "ID of the storage integration"
  value       = snowflake_storage_integration.this.id
}

output "storage_aws_iam_user_arn" {
  description = "AWS IAM user ARN for Snowflake to assume"
  value       = try(snowflake_storage_integration.this.storage_aws_iam_user_arn, null)
}

output "storage_aws_external_id" {
  description = "AWS external ID for Snowflake to use"
  value       = try(snowflake_storage_integration.this.storage_aws_external_id, null)
}
