# --- root/aws/tf/root/outputs.tf ---

############ S3 Bucket Outputs ############################
output "s3_bucket_name" {
  description = "S3 bucket name used for static website"
  value       = module.s3.name
}
output "s3_bucket_region" {
  description = "S3 bucket region"
  value       = module.s3.bucket_region
}
output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.bucket_arn
}
output "s3_versioning_status" {
  description = "S3 bucket versioning status"
  value       = module.s3.versioning_status
}
output "assume_role_policy" {
  description = "Assume role policy document for IAM role"
  value       = local.assume_role_policy
  sensitive   = true
}
############ IAM Role Outputs ############################
output "iam_role_arn" {
  description = "IAM role arn for the Lambda get endpoint function"
  value       = module.iam_role.iam_role_arn
}
output "s3_bucket_policy" {
  description = "S3 bucket policy"
  value       = local.s3_bucket.bucket_policy
  sensitive   = false
}

############ Snowflake Warehouse Outputs ############################
output "snowflake_warehouses" {
  description = "Snowflake warehouses created"
  value       = module.snowflake.warehouses
}