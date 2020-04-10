resource "aws_ssm_parameter" "subnets" {
  name  = "/base/subnets_id"
  value = join(",", aws_subnet.subnets.*.id)
  type  = "String"
}

resource "aws_ssm_parameter" "vpc" {
  name  = "/base/vpc_id"
  value = aws_vpc.main.id
  type  = "String"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "Name"                                      = "vpc-${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "subnets" {
  count = length(var.cluster_azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(var.cluster_azs, count.index)

  tags = {
    "Name" = format(
      "subnet-vpc-%s-%s",
      var.cluster_name,
      element(var.cluster_azs, count.index),
    )
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_route_table" "main_route" {
  count = length(var.cluster_azs)

  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = format(
      "vpc-%s-rt-%s",
      var.cluster_name,
      element(var.cluster_azs, count.index),
    )
  }
}

resource "aws_route_table_association" "control_plane_route" {
  count = length(var.cluster_azs)

  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.main_route[count.index].id
}

resource "aws_internet_gateway" "cluster_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = format("vpc-%s-igw", var.cluster_name)
  }
}

resource "aws_route" "igw_route" {
  count = length(var.cluster_azs)

  route_table_id         = aws_route_table.main_route[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cluster_igw.id
}
