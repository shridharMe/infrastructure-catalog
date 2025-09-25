# Stack Terragrunt Configuration for Production US East 1
# This file reads values from terragrunt.values.hcl and configures the stack

# Include the values from terragrunt.values.hcl
include "values" {
  path = "terragrunt.values.hcl"
}

# Include the root configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Local variables for this stack
locals {
  # Read values directly from the included file
  account_values = read_terragrunt_config("terragrunt.values.hcl")
  
  # Common tags applied to all resources in this stack
  common_tags = {
    Account     = local.account_values.account
    Region      = local.account_values.region
    Environment = local.account_values.environment
    ManagedBy   = "terragrunt"
    Project     = "multi-account-infrastructure"
  }
}

# Inputs passed to all child configurations in this stack
inputs = {
  # Core configuration
  region       = local.account_values.region
  account_id       = local.account_values.account_id
  account          = local.account_values.account
  environment      = local.account_values.environment
  assume_role_arn  = local.account_values.assume_role_arn
  
  # State configuration
  state_bucket     = local.account_values.state_bucket
  state_key        = "${path_relative_to_include()}/terraform.tfstate"
  dynamodb_table   = "terraform-locks-${local.account_values.account}-${local.account_values.region}"
  
  # Tags
  default_tags     = local.common_tags
  
  # S3 module specific inputs
  bucket           = local.account_values.bucket_name
  tags             = local.common_tags
}
