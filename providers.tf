terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
  required_version = ">= 1.0"
}

# Default provider in module specified region
provider "aws" {
  region = var.region
}

# us-east-1 provider for domain names, referenced as us-east-1
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}
