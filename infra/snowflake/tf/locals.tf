# ============================================================================
# Local Values
# ============================================================================

data "aws_region" "current" {
  count = var.enable_aws ? 1 : 0
}

data "aws_caller_identity" "current" {
  count = var.enable_aws ? 1 : 0
}

locals {
  # -------------------------------------------------------------------------
  # Snowflake Core Resources (from JSON files)
  # -------------------------------------------------------------------------
  
  snowflake_core_config = jsondecode(file("${path.module}/input-jsons/snowflake-core-objects.json"))
  warehouses            = local.snowflake_core_config["warehouses"]
  databases             = local.snowflake_core_config["databases"]

  # -------------------------------------------------------------------------
  # AWS Configuration
  # -------------------------------------------------------------------------
  
  aws_s3_config = var.enable_aws ? jsondecode(file("${path.module}/input-jsons/aws-s3.json")) : {}
  
  # -------------------------------------------------------------------------
  # Snowflake Integrations (from JSON files)
  # -------------------------------------------------------------------------
  
  stages_config = jsondecode(file("${path.module}/input-jsons/stages.json"))
  stages        = local.stages_config["stages"]
}
