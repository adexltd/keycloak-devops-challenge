terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket  = "keycloak"
    region  = var.region
    encrypt = true
    key     = "lms-ecs-base-infra/terraform.tfstate"
  }
}
