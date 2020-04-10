terraform {
  backend "local" {
    path = "remote-bucket.tfstate"
  }
}

provider "aws" {
  version = "~> 2.9.0"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "remote-state-bucket" {
  bucket = "rechops-config"
  acl    = "private"

  tags = {
    Name        = "Rechops Platform Remote State Bucket"
    Environment = "Dev"
  }
}
