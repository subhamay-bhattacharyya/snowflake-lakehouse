# --- root/aws/tf/root/terraform.tfvars ---

tags = {
  ProjectName = "Snowflake Lakehouse"
  Owner       = "Subhamay Bhattacharyya"
  Env         = "devl"
  Phase       = "initial"
}

# Snowflake Configuration
# Set these via environment variables or terraform.tfvars.local (gitignored)
# 
# Option 1: Key-Pair Authentication (Recommended - More Secure)
# snowflake_account     = "your-account-identifier"
# snowflake_user        = "your-terraform-user"
# snowflake_private_key = "-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----"
# snowflake_role        = "SYSADMIN"
#
# Option 2: Password Authentication
# snowflake_account  = "your-account-identifier"
# snowflake_user     = "your-terraform-user"
# snowflake_password = "your-password"
# snowflake_role     = "SYSADMIN"