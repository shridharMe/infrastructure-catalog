 
# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders("root.hcl")
}


# include "envcommon" {
#  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/s3-bucket.hcl"
#  expose = true
#}


terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git?ref=master"
}

# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.
# ---------------------------------------------------------------------------------------------------------------------

