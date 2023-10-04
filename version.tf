terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket  = "keycloak-tf"
    region  = "us-east-2"
    encrypt = true
    key     = "state-file/terraform.tfstate"
  }
}
