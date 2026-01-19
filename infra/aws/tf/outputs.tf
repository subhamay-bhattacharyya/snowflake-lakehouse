# --- root/aws/tf/root/outputs.tf ---

############ S3 Bucket Outputs ############################
output "s3_bucket_name" {
  description = "S3 bucket name used for static website"
  value       = module.s3.s3_bucket_name
}
output "s3_bucket_region" {
  description = "S3 bucket region"
  value       = module.s3.s3_bucket_region
}
output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.s3_bucket_arn
}
