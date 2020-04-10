# See: https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
resource "aws_security_group" "nodes" {
  name        = "${var.cluster_name}-nodes"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  tags = {
    "Name"                                      = format("vpc-%s", var.cluster_name)
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "nodes_egress_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "nodes-ingress-self" {
  description = "Allow node to communicate with each other"

  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "-1"

  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "nodes-ingress-cluster" {
  description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"

  type      = "ingress"
  from_port = 1025
  to_port   = 65535
  protocol  = "tcp"

  source_security_group_id = var.sg_control_plane_id
  security_group_id        = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "nodes-ingress-cluster-https" {
  description = "Allow the cluster control plane to communicate with the workers API Server"

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  source_security_group_id = var.sg_control_plane_id
  security_group_id        = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description = "Allow pods to communicate with the cluster API Server"

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = var.sg_control_plane_id
}