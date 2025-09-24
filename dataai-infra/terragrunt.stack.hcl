unit "s3_bucket" {
  source ="git@github.com:shridharMe/infrastructure-catalog.git//units/dataai-infra?ref=main"
  path   = "s3_bucket"

  no_dot_terragrunt_stack = true

  ## Add any additional configuration for the service unit here
}