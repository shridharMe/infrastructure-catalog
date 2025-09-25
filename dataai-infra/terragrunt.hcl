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

# Configure remote state
remote_state {
  backend = "s3"
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  
  config = {
    bucket         = local.account_values.state_bucket
    key            = "${path_relative_to_include("root")}/terraform.tfstate"
    region         = local.account_values.region
    encrypt        = true
    dynamodb_table = "terraform-locks-${local.account_values.account}-${local.account_values.region}"
    
    # Use assume role for cross-account state management
    role_arn = local.account_values.assume_role_arn != "" ? local.account_values.assume_role_arn : null
  }
}

# Generate AWS provider configuration with dynamic values
generate "provider" {
  path      = "terragrunt-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
# AWS provider with dynamic configuration
provider "aws" {
  region = "${local.values.region}"
  
  # Assume role for cross-account deployment
  assume_role {
    role_arn = "${local.values.assume_role_arn}"
  }
  
  # Default tags applied to all resources
  default_tags {
    tags = {
      Account     = "${local.values.account}"
      Region      = "${local.values.region}"
      Environment = "${local.values.environment}"
      ManagedBy   = "terragrunt"
      Project     = "multi-account-infrastructure"
      CreatedBy   = "terragrunt-stack"
    }
  }
}
EOF
}
