# --- root/aws/tf/root/providers.tf ---

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
}

# Configure the Snowflake Provider
provider "snowflake" {
  account     = var.snowflake_account
  user        = var.snowflake_user
  password    = var.snowflake_password != "" ? var.snowflake_password : null
  private_key = var.snowflake_private_key != "" ? var.snowflake_private_key : null
  role        = var.snowflake_role
}