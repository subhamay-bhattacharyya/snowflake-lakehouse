# -- infra/platform/tf/main.tf (Platform Module)
# ============================================================================
# Snowflake Lakehouse - Platform Orchestration
# ============================================================================
#
# ┌─────────────────────────────────────────────────────────────┐
# │  PHASE 1: AWS Resources (infra/aws/tf)                      │
# ├─────────────────────────────────────────────────────────────┤
# │  1. S3 Bucket                                               │
# │  2. IAM Role (initial - with placeholder trust policy)      │
# └─────────────────────────────────────────────────────────────┘
#                             │
#                             ▼
# ┌─────────────────────────────────────────────────────────────┐
# │  PHASE 2: Snowflake Resources (infra/snowflake/tf)          │
# ├─────────────────────────────────────────────────────────────┤
# │  1. Warehouses                                              │
# │  2. Databases                                               │
# │  3. File Formats                                            │
# │  4. Storage Integration ← references IAM Role ARN           │
# │     └─► Outputs: STORAGE_AWS_IAM_USER_ARN                   │
# │                  STORAGE_AWS_EXTERNAL_ID                    │
# │  5. Stages                                                  │
# │  6. Snowpipes                                               │
# └─────────────────────────────────────────────────────────────┘
#                             │
#                             ▼
# ┌─────────────────────────────────────────────────────────────┐
# │  PHASE 3: AWS Trust Policy Update                           │
# ├─────────────────────────────────────────────────────────────┤
# │  Update IAM Role trust policy with Snowflake's              │
# │  STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID       │
# └─────────────────────────────────────────────────────────────┘
#
# ============================================================================

# ----------------------------------------------------------------------------
# Phase 1: AWS Resources (S3 Bucket + IAM Role with placeholder trust)
# ----------------------------------------------------------------------------
module "aws" {
  source = "../../aws/tf"

  # S3 bucket configuration
  s3_config = local.s3_config

  # IAM role configuration (with placeholder trust policy initially)
  iam_role_config = local.iam_role_config

  # Phase 3: Pass Snowflake values for trust policy update (empty on first apply)
  update_trust_policy    = false # Set to true after Phase 2 to update via AWS module
  snowflake_iam_user_arn = ""
  snowflake_external_id  = ""
}

# ----------------------------------------------------------------------------
# Phase 2: Snowflake Resources (COMMENTED OUT)
# ----------------------------------------------------------------------------
module "snowflake" {
  source = "../../snowflake/tf"

  # Pass Snowflake configurations as individual config objects
  warehouse_config           = local.warehouses
  database_config            = local.databases
  schema_config              = local.schemas
  file_format_config         = local.file_formats
  storage_integration_config = local.storage_integrations
  stage_config               = local.stages
  table_config               = local.tables
  snowpipe_config            = local.snowpipes

  depends_on = [module.aws]
}

# ----------------------------------------------------------------------------
# Phase 3: Update IAM Role Trust Policy with Snowflake values
# ----------------------------------------------------------------------------
# Extract the first storage integration's trust values from Snowflake output
locals {
  storage_integration_keys     = keys(module.snowflake.storage_integrations)
  has_storage_integration      = length(local.storage_integration_keys) > 0
  first_storage_integration    = local.has_storage_integration ? module.snowflake.storage_integrations[local.storage_integration_keys[0]] : null
  snowflake_iam_user_arn       = local.first_storage_integration != null ? local.first_storage_integration.storage_aws_iam_user_arn : ""
  snowflake_external_id_output = local.first_storage_integration != null ? local.first_storage_integration.storage_aws_external_id : ""
}

module "aws_iam_role_final" {
  source = "../../aws/tf/modules/iam_role_final"

  enabled                = local.has_storage_integration
  role_name              = local.iam_role_config.role_name
  snowflake_iam_user_arn = local.snowflake_iam_user_arn
  snowflake_external_id  = local.snowflake_external_id_output

  depends_on = [module.snowflake]
}

# ----------------------------------------------------------------------------
# Phase 4: Configure S3 Event Notifications for Snowpipe Auto-Ingest
# ----------------------------------------------------------------------------
locals {
  # Build notification configs from snowpipe outputs
  snowpipe_notifications = [
    for key, pipe in module.snowflake.snowpipes : {
      id            = key
      sqs_arn       = pipe.notification_channel
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = lookup(local.snowpipes[key], "filter_prefix", null)
      filter_suffix = lookup(local.snowpipes[key], "filter_suffix", null)
    } if pipe.notification_channel != null && pipe.notification_channel != ""
  ]
}

module "s3_event_notification" {
  source = "../../aws/tf/modules/s3_event_notification"

  enabled       = length(local.snowpipe_notifications) > 0
  bucket_name   = local.s3_config.bucket_name
  notifications = local.snowpipe_notifications

  depends_on = [module.snowflake, module.aws_iam_role_final]
}
