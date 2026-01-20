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
  
  warehouses_config = jsondecode(file("${path.module}/input-jsons/warehouses.json"))
  warehouses        = local.warehouses_config["warehouses"]

  databases_config = jsondecode(file("${path.module}/input-jsons/databases.json"))
  databases        = local.databases_config["databases"]

  # -------------------------------------------------------------------------
  # AWS Configuration
  # -------------------------------------------------------------------------
  
  aws_s3_config = var.enable_aws ? jsondecode(file("${path.module}/input-jsons/aws-s3.json")) : {}
  
  # -------------------------------------------------------------------------
  # GCP Configuration
  # -------------------------------------------------------------------------
  
  gcp_gcs_config = var.enable_gcp ? jsondecode(file("${path.module}/input-jsons/gcp-gcs.json")) : {}
  
  # -------------------------------------------------------------------------
  # Azure Configuration
  # -------------------------------------------------------------------------
  
  azure_blob_config = var.enable_azure ? jsondecode(file("${path.module}/input-jsons/azure-blob.json")) : {}
  
  # -------------------------------------------------------------------------
  # Snowflake Integrations (from JSON files)
  # -------------------------------------------------------------------------
  
  stages_config = jsondecode(file("${path.module}/input-jsons/stages.json"))
  stages        = local.stages_config["stages"]
}
