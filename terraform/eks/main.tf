data "aws_ssm_parameter" "vpc_id" {
  name = "/base/vpc_id"
}

data "aws_ssm_parameter" "subnets" {
  name = "/base/subnets_id"
}

locals {
  vpc_id    = data.aws_ssm_parameter.vpc_id.value
  subnets_id = split(",", data.aws_ssm_parameter.subnets.value)
}

module "control_plane" {
  source = "./control-plane"

  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  aws_region = var.aws_region

  vpc_id = local.vpc_id
  subnets_id = local.subnets_id
}

module "workers" {
  source = "./workers"

  cluster_name = var.cluster_name
  cluster_endpoint = module.control_plane.endpoint
  cluster_version = var.cluster_version
  cluster_ca_data = module.control_plane.ca_data

  vpc_id = local.vpc_id
  sg_control_plane_id = module.control_plane.security_group_id
  subnets_id = local.subnets_id

  instance_type = var.instance_type
  nodes_min_size = var.nodes_min_size
  nodes_max_size = var.nodes_max_size
}

