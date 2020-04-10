 variable "cluster_name" {
     default = "cluster-prod"
 }

variable "aws_region" {
    default = "us-east-1"
}

variable "cluster_azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
