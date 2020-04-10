variable "cluster_name" {
}

variable "vpc_id" {
}


variable "cluster_endpoint" {
}

variable "cluster_version" {
}

variable "cluster_ca_data" {
}

variable "sg_control_plane_id" {
}

variable "subnets_id" {
  type = list
}

variable "instance_type" {
}

variable "nodes_min_size" {
}

variable "nodes_max_size" {
}

