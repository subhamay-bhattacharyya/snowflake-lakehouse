# ============================================================================
# Local Values
# ============================================================================

locals {
  # -------------------------------------------------------------------------
  # Snowflake Core Resources (from JSON files)
  # -------------------------------------------------------------------------

  snowflake_core_config = jsondecode(file("${path.module}/input-jsons/snowflake-core-objects.json"))

  # Add prefix to warehouse names
  warehouses = {
    for key, wh in local.snowflake_core_config["warehouses"] : key => merge(wh, {
      name = var.object_prefix != "" ? "${var.object_prefix}_${wh.name}" : wh.name
    })
  }

  # Add prefix to database names
  databases = {
    for key, db in local.snowflake_core_config["databases"] : key => merge(db, {
      name = var.object_prefix != "" ? "${var.object_prefix}_${db.name}" : db.name
    })
  }

  # Extract and flatten file formats from all databases
  file_formats = flatten([
    for db_key, db in local.snowflake_core_config["databases"] : [
      for ff_key, ff in lookup(db, "file_formats", {}) : merge(ff, {
        database = var.object_prefix != "" ? "${var.object_prefix}_${db.name}" : db.name
        schema   = "UTIL" # File formats are created in UTIL schema
      })
    ]
  ])

  # Extract and flatten storage integrations from all databases
  storage_integrations = flatten([
    for db_key, db in local.snowflake_core_config["databases"] : [
      for si_key, si in lookup(db, "storage_integrations", {}) : merge(si, {
        database = var.object_prefix != "" ? "${var.object_prefix}_${db.name}" : db.name
      })
    ]
  ])

  # Extract and flatten stages from all databases
  stages = flatten([
    for db_key, db in local.snowflake_core_config["databases"] : [
      for stage_key, stage in lookup(db, "stages", {}) : merge(stage, {
        database = var.object_prefix != "" ? "${var.object_prefix}_${db.name}" : db.name
      })
    ]
  ])

  # Extract and flatten snowpipes from all databases
  snowpipes = flatten([
    for db_key, db in local.snowflake_core_config["databases"] : [
      for pipe_key, pipe in lookup(db, "snowpipes", {}) : merge(pipe, {
        database = var.object_prefix != "" ? "${var.object_prefix}_${db.name}" : db.name
      })
    ]
  ])
}
