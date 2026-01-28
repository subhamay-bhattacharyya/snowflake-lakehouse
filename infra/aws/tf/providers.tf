# -- infra/aws/tf/providers.tf (Child Module)

# # Configure the AWS Provider
# provider "aws" {
#   region = var.aws_region
#   default_tags {
#     tags = var.tags
#   }
# }

# # Configure the Snowflake Provider
# provider "snowflake" {
#   organization_name = local.snowflake_org_name
#   account_name      = local.snowflake_account_name
#   user              = local.snowflake_user
#   role              = local.snowflake_role

#   # Use private key authentication when available, otherwise use password
#   authenticator          = local.snowflake_private_key != "" ? "JWT" : "SNOWFLAKE"
#   private_key            = local.snowflake_private_key != "" ? local.snowflake_private_key : null
#   private_key_passphrase = local.snowflake_private_key_passphrase != "" ? local.snowflake_private_key_passphrase : null
#   password               = local.snowflake_private_key == "" && local.snowflake_password != "" ? local.snowflake_password : null
# }