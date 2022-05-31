locals {
  aws_auths = {
    profile          = var.aws_profile
    region           = var.region
    credentials_file = var.credentials_file
  }

  nodes = {

    #    core = {
    #      create_launch_template = false
    #      create_iam_role        = false
    #      iam_role_arn           = module.node_role.role_arn
    #
    #      min_size     = 1
    #      max_size     = 6
    #      desired_size = 1
    #
    #      instance_types = ["t3.medium"]
    #      capacity_type  = "ON_DEMAND"
    #
    #      #      create_iam_role            = false
    #      #      iam_role_attach_cni_policy = false
    #      #      iam_role_arn               = aws_iam_role.worker_role.arn
    #
    #      labels = {
    #        Environment = "test"
    #        GithubRepo  = "terraform-aws-eks"
    #        GithubOrg   = "terraform-aws-modules"
    #      }
    #
    #      taints = {
    #        system = {
    #          key    = "dedicated"
    #          value  = "core"
    #          effect = "NO_SCHEDULE"
    #        }
    #      }
    #
    #      tags = merge(var.tags, {
    #        "k8s.io/cluster-autoscaler/enabled"             = "true",
    #        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    #      })
    #    }
    #
    #    ingress = {
    #      create_launch_template = false
    #      create_iam_role        = false
    #      iam_role_arn           = module.node_role.role_arn
    #
    #      min_size     = 1
    #      max_size     = 3
    #      desired_size = 1
    #
    #      instance_types = ["t3.medium"]
    #      capacity_type  = "ON_DEMAND"
    #
    #      #      create_iam_role            = false
    #      #      iam_role_attach_cni_policy = false
    #      #      iam_role_arn               = aws_iam_role.worker_role.arn
    #
    #      labels = {
    #        Environment = "test"
    #        GithubRepo  = "terraform-aws-eks"
    #        GithubOrg   = "terraform-aws-modules"
    #      }
    #
    #      taints = {
    #        system = {
    #          key    = "dedicated"
    #          value  = "ingress"
    #          effect = "NO_SCHEDULE"
    #        }
    #      }
    #
    #      tags = merge(var.tags, {
    #        "k8s.io/cluster-autoscaler/enabled"             = "true",
    #        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    #      })
    #    }

    workers = {
      cluster_name                      = var.cluster_name
      cluster_primary_security_group_id = aws_security_group.control_plane_sg.id
      create_security_group             = false
      vpc_security_group_ids            = [aws_security_group.node_group_sg.id]

      create_launch_template = true
      create_iam_role         = false
      iam_role_arn            = module.node_role.role_arn

      labels = {}
      taints = {}
      tags   = merge(var.tags, {
        "k8s.io/cluster-autoscaler/enabled"             = "true",
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      })

      #ami_id         = "ami-02da89ddc4cc9ed18"
      ami_type      = "AL2_x86_64"
      capacity_type = "ON_DEMAND"

      min_size     = 1
      max_size     = 6
      desired_size = 3

      subnet_ids = module.vpc.private_subnets

      update_config = {
        max_unavailable = 1
      }
    }
  }
}