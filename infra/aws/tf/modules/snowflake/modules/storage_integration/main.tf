# --- Snowflake Storage Integration Sub-Module ---

resource "snowflake_storage_integration" "this" {
  name    = var.name
  comment = var.comment
  type    = "EXTERNAL_STAGE"

  enabled = var.enabled

  storage_allowed_locations = var.storage_allowed_locations
  storage_blocked_locations = var.storage_blocked_locations

  storage_provider       = var.storage_provider
  storage_aws_role_arn   = var.storage_provider == "S3" ? var.storage_aws_role_arn : null
  storage_aws_object_acl = var.storage_provider == "S3" ? var.storage_aws_object_acl : null
}
