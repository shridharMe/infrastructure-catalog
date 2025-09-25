terraform {
  source = "git@github.com:shridharMe/terraform-aws-s3-bucket.git?ref=master"
}

locals {
  config = read_terragrunt_config("terragrunt-values.hcl", {})
}

inputs = {
  region=local.config.region
  bucket_name     = local.config.bucket_name
}
