 
# Include the parent terragrunt.hcl that contains the inputs and remote state
include "parent" {
  path = find_in_parent_folders("terragrunt.hcl")
}

# Include the root configuration for global settings
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Local variables for accessing parent values
locals {
  parent_config = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  account_values = local.parent_config.locals.account_values
}

# Generate AWS provider configuration
generate "provider" {
  path      = "terragrunt-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
# AWS provider with dynamic configuration
provider "aws" {
  region = "${local.account_values.region}"
  
  # Assume role for cross-account deployment (if provided)
  dynamic "assume_role" {
    for_each = "${local.account_values.assume_role_arn}" != "" ? [1] : []
    content {
      role_arn = "${local.account_values.assume_role_arn}"
    }
  }
  
  # Default tags applied to all resources
  default_tags {
    tags = {
      Account     = "${local.account_values.account}"
      Region      = "${local.account_values.region}"
      Environment = "${local.account_values.environment}"
      ManagedBy   = "terragrunt"
      Project     = "multi-account-infrastructure"
      CreatedBy   = "terragrunt-stack"
    }
  }
}
EOF
}

terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git?ref=master"
}

# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.
# ---------------------------------------------------------------------------------------------------------------------

