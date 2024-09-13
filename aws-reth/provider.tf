terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.56"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = { Namespace = var.namespace }
  }
}