resource "aws_iam_role" "nodes_role" {
  name = "nodes.k8.${var.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

# TODO: Restrict to the ASGs of this cluster
# See: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#permissions
resource "aws_iam_policy" "k8s_cluster_autoscaler" {
  name        = "eks_cluster_autoscaler_policy"
  description = "Policy to grant the ability to autoscale the EKS cluster"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "autoscaling:DescribeLaunchConfigurations"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

# resource "aws_iam_policy" "pull_images_from_ecr" {
#   name        = "pull_images_from_ecr"
#   description = "Policy to grant the ability to the EKS worker nodes to pull images from ECR"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ecr:GetAuthorizationToken",
#                 "ecr:BatchCheckLayerAvailability",
#                 "ecr:GetDownloadUrlForLayer",
#                 "ecr:GetRepositoryPolicy",
#                 "ecr:DescribeRepositories",
#                 "ecr:ListImages",
#                 "ecr:BatchGetImage"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
# EOF

# }

resource "aws_iam_role_policy_attachment" "node-cluster_auto_scaler" {
  policy_arn = aws_iam_policy.k8s_cluster_autoscaler.arn
  role       = aws_iam_role.nodes_role.name
}

# TODO: Isn't this the same as AmazonEC2ContainerRegistryReadOnly ?
# resource "aws_iam_role_policy_attachment" "node-pull_images_from_ecr" {
#   policy_arn = aws_iam_policy.pull_images_from_ecr.arn
#   role       = aws_iam_role.nodes_role.name
# }

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes_role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes_role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes_role.name
}

resource "aws_iam_instance_profile" "nodes_profile" {
  name = "${var.cluster_name}-nodes"
  role = aws_iam_role.nodes_role.name
}

