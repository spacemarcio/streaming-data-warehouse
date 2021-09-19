provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
      bucket = "stockprices-iac-state"
      key = "terraform.state"
      region = "us-east-2"
  }
}