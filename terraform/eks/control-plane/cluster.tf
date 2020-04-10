resource "aws_eks_cluster" "cluster" {
  name = var.cluster_name

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html
  version  = var.cluster_version
  role_arn = aws_iam_role.service_role.arn

  vpc_config {
    security_group_ids = [aws_security_group.control_plane.id]
    subnet_ids         = var.subnets_id
  }
}
