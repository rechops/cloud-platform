# Alternatively we could use a fixed version according to the table in
# https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
data "aws_ami" "nodes" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

data "template_file" "nodes_userdata" {
  template = file("${path.module}/workers-userdata.sh")

  vars = {
    cluster_name       = var.cluster_name
    apiserver_endpoint = var.cluster_endpoint
    cluster_ca         = var.cluster_ca_data
  }
}


resource "aws_launch_configuration" "nodes" {
  name_prefix = "nodes.k8.${var.cluster_name}-"

  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.nodes_profile.name
  image_id                    = data.aws_ami.nodes.id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.nodes.id]
  user_data_base64            = base64encode(data.template_file.nodes_userdata.rendered)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nodes" {
  count = length(var.subnets_id)

  vpc_zone_identifier = [var.subnets_id[count.index]]
  name                = "nodes-${var.subnets_id[count.index]}.k8.${var.cluster_name}"

  launch_configuration = aws_launch_configuration.nodes.id

  min_size = var.nodes_min_size
  max_size = var.nodes_max_size

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "nodes-${var.subnets_id[count.index]}.k8.${var.cluster_name}"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = false
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = "true"
    propagate_at_launch = false
  }
}

