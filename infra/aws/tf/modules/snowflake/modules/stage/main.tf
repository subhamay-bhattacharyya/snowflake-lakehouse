# --- Snowflake Stage Sub-Module ---

resource "snowflake_stage" "this" {
  name                = var.name
  database            = var.database
  schema              = var.schema
  url                 = var.url
  storage_integration = var.storage_integration_name
  comment             = var.comment

  file_format = var.file_format != null ? var.file_format : null
}
