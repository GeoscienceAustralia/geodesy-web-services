terraform {
  required_version = "~> 0.12.0"
  backend "s3" {}
}

provider "aws" {
  region  = var.region
  version = "~> 2.22.0"
}
