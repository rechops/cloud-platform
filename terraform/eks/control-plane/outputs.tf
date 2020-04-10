output "security_group_id" {
    value = aws_security_group.control_plane.id
}

output "endpoint" {
    value = aws_eks_cluster.cluster.endpoint
}

output "ca_data" {
    value = aws_eks_cluster.cluster.certificate_authority[0].data
}