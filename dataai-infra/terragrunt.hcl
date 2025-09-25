# Root Terragrunt Configuration for Infrastructure Catalog
# This file should be placed in your git@github.com:shridharMe/infrastructure-catalog.git//dataai-infra/terragrunt.hcl

# Remote state configuration with account-specific bucket
remote_state {
  backend = "s3"
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  
  config = {
    # Use account-specific state bucket
    bucket = get_env("TG_STATE_BUCKET", "default-state-bucket")
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = get_env("TG_REGION", "us-east-1")
    
    # Enable encryption and versioning
    encrypt = true
    
    # DynamoDB table for state locking (account-specific)
    dynamodb_table = "terraform-locks-${get_env("TG_ACCOUNT", "default")}-${get_env("TG_REGION", "us-east-1")}"
    
    # S3 bucket settings
    skip_bucket_versioning             = false
    skip_bucket_ssencryption           = false
    skip_bucket_root_access            = false
    skip_bucket_enforced_tls           = false
    skip_bucket_public_access_blocking = false
  }
}

# Generate AWS provider with assume role configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider with assume role configuration
provider "aws" {
  region = var.aws_region
  
  # Assume role for cross-account deployment
  assume_role {
    role_arn = var.assume_role_arn
  }
  
  # Default tags applied to all resources
  default_tags {
    tags = var.default_tags
  }
}
EOF
}

# Generate common variables
generate "variables" {
  path      = "variables.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "account" {
  description = "Account name (e.g., control-plane, production)"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "assume_role_arn" {
  description = "ARN of the role to assume for deployment"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}
EOF
}

# Local variables for common configuration
locals {
  # Common tags applied to all resources
  common_tags = {
    Account     = get_env("TG_ACCOUNT", "unknown")
    Region      = get_env("TG_REGION", "unknown")
    Environment = get_env("TG_ENVIRONMENT", "unknown")
    ManagedBy   = "terragrunt"
    Project     = "multi-account-infrastructure"
  }
}

# Common inputs passed to all child configurations
inputs = {
  aws_region       = get_env("TG_REGION", "us-east-1")
  account_id       = get_env("TG_ACCOUNT_ID", "")
  account          = get_env("TG_ACCOUNT", "")
  environment      = get_env("TG_ENVIRONMENT", "")
  assume_role_arn  = get_env("TG_ASSUME_ROLE_ARN", "")
  default_tags     = local.common_tags
}
