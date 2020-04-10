variable "cluster_name" {
    default = "platform"
}

variable "aws_region" {
    default = "us-east-1"
}

variable "cluster_version" {
    default = "1.15"
}

variable "instance_type" {
    type    = string
    default = "t3.micro"
}

variable "nodes_min_size" {
    type = number
    default = 1
}

variable "nodes_max_size" {
    type = number
    default = 2
}
