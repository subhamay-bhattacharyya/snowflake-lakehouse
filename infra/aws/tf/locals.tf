# --- root/aws/tf/root/locals.tf ---

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_kms_key" "kms" { key_id = local.s3_bucket.kms_key_alias }

locals {
  current_region = data.aws_region.current.id

  s3_bucket_config  = jsondecode(file("./input-jsons/s3-bucket.json"))
  warehouses_config = jsondecode(file("./input-jsons/warehouses.json"))

  s3_bucket = {
    bucket_name   = "${var.project_name}-${local.s3_bucket_config["s3-bucket-name"]}-${var.environment}-${local.current_region}"
    versioning    = local.s3_bucket_config["s3-versioning"],
    kms_key_alias = startswith(local.s3_bucket_config["kms-key-alias"], "alias/") ? local.s3_bucket_config["kms-key-alias"] : "alias/${local.s3_bucket_config["kms-key-alias"]}"
    bucket_policy = templatefile("./templates/s3-bucket-policy.tpl", {
      aws_account_id = data.aws_caller_identity.current.account_id
      bucket_name    = "${local.s3_bucket_config["s3-bucket-name"]}-${local.current_region}"
    })
  }

  have_sf = length(trimspace(var.snowflake_principal_arn)) > 0 && length(trimspace(var.snowflake_external_id)) > 0
  assume_role_policy = local.have_sf ? jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { AWS = var.snowflake_principal_arn },
      Action    = "sts:AssumeRole",
      Condition = { StringEquals = { "sts:ExternalId" = var.snowflake_external_id } }
    }]
    }) : jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
      Action    = "sts:AssumeRole"
    }]
  })

  iam_role = {
    storage_name       = local.s3_bucket_config["storage-name"]
    assume_role_policy = local.assume_role_policy
    s3_bucket_arn      = module.s3.bucket_arn
    kms_key_arn        = data.aws_kms_key.kms.arn
  }

  warehouses = local.warehouses_config["warehouses"]

  # Map uppercase GitHub secrets to lowercase Terraform variables
  # Use uppercase vars if set, otherwise fall back to lowercase vars
  snowflake_account_input = var.SNOWFLAKE_ACCOUNT != "" ? var.SNOWFLAKE_ACCOUNT : (
    var.snowflake_organization_name != "" && var.snowflake_account_name != "" ?
    "${var.snowflake_organization_name}-${var.snowflake_account_name}" : ""
  )

  # Split account identifier (format: ORGNAME-ACCOUNTNAME or ORGNAME.REGION.CLOUD)
  snowflake_account_parts = local.snowflake_account_input != "" ? split("-", local.snowflake_account_input) : []

  # Derived Snowflake configuration
  snowflake_org_name               = length(local.snowflake_account_parts) > 0 ? local.snowflake_account_parts[0] : ""
  snowflake_account_name           = length(local.snowflake_account_parts) > 1 ? local.snowflake_account_parts[1] : ""
  snowflake_user                   = var.SNOWFLAKE_USER != "" ? var.SNOWFLAKE_USER : var.snowflake_user
  snowflake_password               = var.SNOWFLAKE_PASSWORD != "" ? var.SNOWFLAKE_PASSWORD : var.snowflake_password
  snowflake_private_key            = var.SNOWFLAKE_PRIVATE_KEY != "" ? var.SNOWFLAKE_PRIVATE_KEY : var.snowflake_private_key
  snowflake_private_key_passphrase = var.SNOWFLAKE_PRIVATE_KEY_PASSPHRASE != "" ? var.SNOWFLAKE_PRIVATE_KEY_PASSPHRASE : var.snowflake_private_key_passphrase
  snowflake_role                   = var.SNOWFLAKE_ROLE != "" ? var.SNOWFLAKE_ROLE : var.snowflake_role
}



# locals {
#   kms_alias = startswith(var.encryption_key_ref, "alias/") ? var.encryption_key_ref : "alias/${var.encryption_key_ref}"
#   prefix = trimspace(var.storage_prefix)
#   prefix_norm = local.prefix == "" ? "" : (endswith(local.prefix, "/") ? local.prefix : "${local.prefix}/")
#   storage_url = "s3://${var.storage_name}/${local.prefix_norm}"

#   have_sf = length(trimspace(var.snowflake_principal_arn)) > 0 && length(trimspace(var.snowflake_external_id)) > 0

# assume_role_policy = local.have_sf ? jsonencode({
#   Version = "2012-10-17",
#   Statement = [{
#     Effect = "Allow",
#     Principal = { AWS = var.snowflake_principal_arn },
#     Action = "sts:AssumeRole",
#     Condition = { StringEquals = { "sts:ExternalId" = var.snowflake_external_id } }
#   }]
# }) : jsonencode({
#   Version = "2012-10-17",
#   Statement = [{
#     Effect = "Allow",
#     Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
#     Action = "sts:AssumeRole"
#   }]
# })
# }