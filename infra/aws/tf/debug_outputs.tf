# Temporary debug outputs
output "debug_snowflake_org_name" {
  value     = local.snowflake_org_name
  sensitive = false
}

output "debug_snowflake_account_name" {
  value     = local.snowflake_account_name
  sensitive = false
}

output "debug_snowflake_user" {
  value     = local.snowflake_user
  sensitive = false
}

output "debug_has_password" {
  value     = local.snowflake_password != "" ? "yes" : "no"
  sensitive = true
}

output "debug_has_private_key" {
  value     = local.snowflake_private_key != "" ? "yes" : "no"
  sensitive = true
}

output "debug_private_key_length" {
  value     = length(local.snowflake_private_key)
  sensitive = true
}

output "debug_private_key_starts_with" {
  value     = local.snowflake_private_key != "" ? substr(local.snowflake_private_key, 0, min(30, length(local.snowflake_private_key))) : "empty"
  sensitive = true
}
