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
