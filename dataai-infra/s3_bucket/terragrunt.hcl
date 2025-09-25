# Include the root configuration for global settings
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Local variables to read values from terragrunt.values.hcl
locals {
  values = read_terragrunt_config(find_in_parent_folders("terragrunt.values.hcl"))
}


terraform {
  source = "git@github.com:shridharMe/infrastructure-catalog.git//dataai-infra/s3_bucket?ref=main"
}

# Inputs passed to the Terraform module
inputs = {
  # Core configuration
  region          = local.values.region
  account         = local.values.account
  account_id      = local.values.account_id
  environment     = local.values.environment
  assume_role_arn = local.values.assume_role_arn
  
  # S3 bucket configuration
  bucket_name     = local.values.bucket_name
  
  # State configuration
  state_bucket    = local.values.state_bucket
  
  # Tags
  default_tags = {
    Account     = local.values.account
    Region      = local.values.region
    Environment = local.values.environment
    ManagedBy   = "terragrunt"
    Project     = "multi-account-infrastructure"
    CreatedBy   = "terragrunt-stack"
  }
}
