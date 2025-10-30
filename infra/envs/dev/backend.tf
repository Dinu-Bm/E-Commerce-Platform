terraform {
  backend "s3" {
    bucket = "tfstate-ha-ecommerce-dev-CHANGE-ME"
    key    = "infra/dev/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
  }
}
