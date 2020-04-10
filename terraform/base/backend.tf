terraform {
  backend "s3" {
    bucket = "rechops-config"
    key    = "base-platform.tfstate"
    region = "us-east-1"
  }
}
