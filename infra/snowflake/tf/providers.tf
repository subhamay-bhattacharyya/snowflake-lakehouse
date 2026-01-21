# ============================================================================
# Terraform and Provider Configuration
# ============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 0.98"
    }
  }
}

# ============================================================================
# Snowflake Provider Configuration
# ============================================================================
# Authentication: Uses private key authentication (passkey)
# The private key should be in PEM format without encryption
provider "snowflake" {
  organization_name = "AGXUOKJ"
  account_name      = "JKC15404"
  user              = "GH_ACTIONS_USER"
  authenticator     = "JWT"
  private_key       = file(var.snowflake_private_key_path)
  role              = "ACCOUNTADMIN"
  warehouse         = "UTIL_WH"
}
