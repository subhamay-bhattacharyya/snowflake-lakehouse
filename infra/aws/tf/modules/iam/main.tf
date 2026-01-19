# --- root/aws/tf/modules/iam/main.tf ---

resource "aws_iam_role" "this" {
  name               = "snowflake-extstage-${var.iam_role.storage_name}-role"
  assume_role_policy = var.iam_role.assume_role_policy
}

resource "aws_iam_role_policy" "this" {

  role = aws_iam_role.this.id
  name = "snowflake-extstage-${var.iam_role.storage_name}-role-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = "${var.iam_role.s3_bucket_arn}"
      },
      { Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Resource = "${var.iam_role.s3_bucket_arn}/*"
      },
      { Effect   = "Allow",
        Action   = ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"],
        Resource = var.iam_role.kms_key_arn
      }
    ]
  })
}
