unit "s3_bucket" {
  source ="git@github.com:shridharMe/infrastructure-catalog.git//dataai-infra/s3_bucket?ref=main"
  path   = "s3_bucket"
  values = {
    environment = "dataai-sandbox"
    bucket_name = "infra-dataai-sandbox-eu-central-1"
    region      = "eu-central-1"
    account     = "dataai-sandbox"
  }
  no_dot_terragrunt_stack = true

  ## Add any additional configuration for the service unit here
}
