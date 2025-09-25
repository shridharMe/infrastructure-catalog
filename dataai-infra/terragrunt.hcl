# Root Terragrunt Configuration
# This provides common configuration for all stacks

# Global locals that can be used by all child configurations
locals {
  # Global tags applied to all resources
  global_tags = {
    ManagedBy = "terragrunt"
    Project   = "multi-account-infrastructure"
    CreatedBy = "terragrunt-stack"
  }
}

# Generate backend configuration dynamically
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
# Backend configuration for Terraform state
terraform {
  backend "s3" {
    bucket         = var.state_bucket
    key            = var.state_key
    region         = var.region
    encrypt        = true
    dynamodb_table = var.dynamodb_table
    
    # S3 bucket security settings
    skip_bucket_versioning             = false
    skip_bucket_ssencryption           = false
    skip_bucket_root_access            = false
    skip_bucket_enforced_tls           = false
    skip_bucket_public_access_blocking = false
  }
}
EOF
}

# Generate AWS provider configuration dynamically
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
# AWS Provider Configuration
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS provider with dynamic configuration
provider "aws" {
  region = var.region
  
  # Assume role for cross-account deployment (if provided)
  dynamic "assume_role" {
    for_each = var.assume_role_arn != "" ? [1] : []
    content {
      role_arn = var.assume_role_arn
    }
  }
  
  # Default tags applied to all resources
  default_tags {
    tags = var.default_tags
  }
}
EOF
}

# Generate common variables that all configurations will need
generate "variables" {
  path      = "variables.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
# Common variables used across all configurations

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
}

variable "state_key" {
  description = "S3 key for Terraform state file"
  type        = string
  default     = "terraform.tfstate"
}

variable "dynamodb_table" {
  description = "DynamoDB table for state locking"
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
  default     = ""
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}
EOF
}

# Configure Terraform settings
terraform {
  # Retry on common transient errors
  retryable_errors = [
    "(?s).*Error installing provider.*tcp.*connection reset by peer.*",
    "(?s).*ssh_exchange_identification.*Connection closed by remote host.*",
    "(?s).*Error configuring the backend.*timeout.*",
    "(?s).*Error installing provider.*TLS handshake timeout.*"
  ]

  # Automatically format Terraform code
  extra_arguments "auto_format" {
    commands  = ["plan", "apply"]
    arguments = ["-compact-warnings"]
  }
}
