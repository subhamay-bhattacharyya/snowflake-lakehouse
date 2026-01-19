# --- root/aws/tf/modules/s3/main.tf ---

resource "aws_s3_bucket" "this" {
  bucket        = var.s3_static_website["s3-bucket-name"]
  force_destroy = true

}
