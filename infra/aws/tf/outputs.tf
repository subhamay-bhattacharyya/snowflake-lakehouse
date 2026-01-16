# ============================================================================
# AWS Infrastructure Outputs
# ============================================================================

output "raw_data_bucket_name" {
  description = "Name of the raw data S3 bucket"
  value       = aws_s3_bucket.raw_data.id
}

output "raw_data_bucket_arn" {
  description = "ARN of the raw data S3 bucket"
  value       = aws_s3_bucket.raw_data.arn
}

output "processed_data_bucket_name" {
  description = "Name of the processed data S3 bucket"
  value       = aws_s3_bucket.processed_data.id
}

output "processed_data_bucket_arn" {
  description = "ARN of the processed data S3 bucket"
  value       = aws_s3_bucket.processed_data.arn
}

output "snowflake_role_arn" {
  description = "ARN of the IAM role for Snowflake"
  value       = aws_iam_role.snowflake_role.arn
}

output "snowflake_role_name" {
  description = "Name of the IAM role for Snowflake"
  value       = aws_iam_role.snowflake_role.name
}
