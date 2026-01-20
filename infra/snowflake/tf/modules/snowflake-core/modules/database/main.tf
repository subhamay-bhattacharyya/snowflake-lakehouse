# ============================================================================
# Snowflake Database Sub-Module
# ============================================================================

resource "snowflake_database" "this" {
  name    = var.name
  comment = var.comment
}

resource "snowflake_schema" "schemas" {
  for_each = { for schema in var.schemas : schema.name => schema }

  database = snowflake_database.this.name
  name     = each.value.name
  comment  = lookup(each.value, "comment", "")

  depends_on = [snowflake_database.this]
}
