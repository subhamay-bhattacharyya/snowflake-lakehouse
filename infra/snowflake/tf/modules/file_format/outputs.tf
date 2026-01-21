# ============================================================================
# Snowflake File Format Outputs
# ============================================================================

output "file_formats" {
  description = "Map of file format names to their details"
  value = {
    for k, v in snowflake_file_format.this : k => {
      name        = v.name
      id          = v.id
      database    = v.database
      schema      = v.schema
      format_type = v.format_type
    }
  }
}
