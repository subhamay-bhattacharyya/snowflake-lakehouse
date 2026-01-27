# -- infra/platform/tf/debug-outputs.tf (Platform Module)
# ============================================================================
# Debug Outputs - Uncomment as needed for troubleshooting
# ============================================================================

# output "config" {
#   description = "Input configuration for verification"
#   value       = var.config
# }

# output "s3_config" {
#   description = "Computed S3 configuration"
#   value       = local.s3_config
# }

# output "iam_role_config" {
#   description = "IAM Role configuration"
#   value       = local.iam_role_config
# }

# ----------------------------------------------------------------------------
# Snowflake Outputs (COMMENTED OUT - Phase 2 not deployed)
# ----------------------------------------------------------------------------
# output "snowflake_aws_iam_user_arns" {
#   description = "Snowflake IAM user ARNs - use in AWS IAM trust policy"
#   value       = module.snowflake.storage_integrations.bronze_s3.storage_aws_iam_user_arn
# }

# output "snowflake_external_id" {
#   description = "External ID for Snowflake IAM trust policy"
#   value       = module.snowflake.storage_integrations.bronze_s3.storage_aws_external_id
#   sensitive   = false
# }
# output "local_storage_integrations" {
#   description = "Storage integrations"
#   value       = local.storage_integrations
# }
