# --- root/aws/tf/root/main.tf ---

module "s3" {
  source    = "./modules/s3"
  s3_bucket = local.s3_bucket
}

module "iam_role" {
  source   = "./modules/iam"
  iam_role = local.iam_role
}

module "snowflake" {
  source = "./modules/snowflake"

  warehouses = local.warehouses
}