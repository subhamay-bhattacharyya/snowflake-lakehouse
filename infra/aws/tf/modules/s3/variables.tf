# --- root/aws/tf/modules/s3/variables.tf ---

variable "s3_bucket" {
  description = "S3 bucket configuration"
  type        = map(any)
}