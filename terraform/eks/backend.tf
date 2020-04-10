terraform {
  backend "s3" {
    bucket = "rechops-config"
    key    = "platform-eks.tfstate"
    region = "us-east-1"
  }
}