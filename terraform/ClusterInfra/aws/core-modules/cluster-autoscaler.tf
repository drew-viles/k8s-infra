resource "aws_iam_role" "cluster_autoscaler_oidc" {
  name        = "AmazonEKSClusterAutoscalerRole"
  description = "Amazon EKS - Cluster autoscaler role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : var.oidc_arn
        },
        "Condition" : {
          "StringEquals" : {
            "${var.oidc_host}:sub" : [
              "system:serviceaccount:kube-system:cluster-autoscaler"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "AmazonEKSClusterAutoscalerPolicy"
  description = "Amazon EKS - Cluster autoscaler role Policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Resource": ["*"]
      },
      {
        "Effect": "Allow",
        "Action": [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeInstanceTypes",
          "eks:DescribeNodegroup"
        ],
        "Resource": ["*"]
      }
    ]
  }
  )
}

resource "aws_iam_role_policy_attachment" "attach_autoscaler_policy" {
  role       = aws_iam_role.cluster_autoscaler_oidc.name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
}


resource "helm_release" "cluster_autoscaler" {
  name             = "cluster-autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = "kube-system"
  create_namespace = false
  version          = local.cluster_autoscaler_version

  values = [
    templatefile("${path.module}/helm-values/cluster_autoscaler.yaml", {
      autoscaler_role = aws_iam_role.cluster_autoscaler_oidc.arn,
      cluster_name    = var.cluster_name
      cloud           = "aws"
    })
  ]
  depends_on = [aws_iam_role.cluster_autoscaler_oidc, helm_release.kube-prometheus-stack]
}