
# See: https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
resource "aws_security_group" "control_plane" {
  name        = format("vpc-%s", var.cluster_name)
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    "Name"                                      = format("vpc-%s", var.cluster_name)
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "control_plane_egress_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "cluster-ingress-https" {
  description = "Ingress to the cluster API Server"

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id = aws_security_group.control_plane.id
  cidr_blocks       = ["0.0.0.0/0"]
}

