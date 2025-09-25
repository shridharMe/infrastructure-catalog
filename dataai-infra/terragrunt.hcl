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
  # Common tags applied to all resources in this stack
  common_tags = {
    Account     = include.values.inputs.account
    Region      = include.values.inputs.region
    Environment = include.values.inputs.environment
    ManagedBy   = "terragrunt"
    Project     = "multi-account-infrastructure"
  }
}

# Inputs passed to all child configurations in this stack
inputs = {
  # Core configuration
  aws_region       = include.values.inputs.region
  account_id       = include.values.inputs.account_id
  account          = include.values.inputs.account
  environment      = include.values.inputs.environment
  assume_role_arn  = include.values.inputs.assume_role_arn
  
  # State configuration
  state_bucket     = include.values.inputs.state_bucket
  state_key        = "${path_relative_to_include()}/terraform.tfstate"
  dynamodb_table   = "terraform-locks-${include.values.inputs.account}-${include.values.inputs.region}"
  
  # Tags
  default_tags     = local.common_tags
  
  # S3 module specific inputs
  bucket           = include.values.inputs.bucket_name
  tags             = local.common_tags
}
