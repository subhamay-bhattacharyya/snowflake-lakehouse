# --- root/aws/tf/modules/iam/variables.tf ---

variable "iam_role" {
  description = "IAM Role and Policy configuration for Snowflake external stage"
  type        = any
}