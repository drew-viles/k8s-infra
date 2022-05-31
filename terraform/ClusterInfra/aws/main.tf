resource "aws_kms_key" "encryption_key" {
  description             = "eks_encryption_key"
  deletion_window_in_days = 7
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.21.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  create_iam_role = false
  iam_role_arn    = module.cluster_role.role_arn

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.encryption_key.arn
      resources        = ["secrets"]
    }
  ]

  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  cluster_service_ipv4_cidr = "10.100.0.0/16"
  cluster_ip_family         = "ipv4"

  create_cluster_security_group = false
  cluster_security_group_id     = aws_security_group.control_plane_sg.id
  create_node_security_group    = false
  node_security_group_id        = aws_security_group.node_sg.id

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      version           = "v1.8.7-eksbuild.1"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
      version           = "v1.22.6-eksbuild.1"
    }
    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
      version           = "v1.11.0-eksbuild.1"
    }
  }

  cluster_enabled_log_types = ["audit", "api", "authenticator", "controllerManager", "scheduler"]

  enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size       = var.disk_size
    instance_types  = var.instance_types
    disk_encrypted  = true
    disk_kms_key_id = aws_kms_key.encryption_key.id
    timeouts        = {
      create = "15m"
      update = "15m"
      delete = "15m"
    }
  }
  eks_managed_node_groups = local.nodes

  #  iam_role_tags            = var.tags
  #  cluster_tags             = var.tags
  #  node_security_group_tags = var.tags
  tags       = var.tags
  depends_on = [aws_security_group.control_plane_sg, aws_security_group.node_sg, aws_security_group.node_group_sg]
}

#module "core_addons" {
#  source = "./core-modules"
#
#  cluster_name      = var.cluster_name
#  region            = var.region
#  cluster_domains   = var.cluster_domains
#  aws_account_id    = var.account_id
#  vpc_id            = module.vpc.vpc_id
#  certmanager       = var.cert_manager
#  loadbalancer_type = var.loadbalancer_type
#  oidc_arn          = module.eks.oidc_provider_arn
#  oidc_host         = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
#  external_dns      = {
#    txt_owner = var.cluster_name
#    prefix    = "k8s-dns-"
#    args      = ["--aws-api-retries=3", "--aws-batch-change-size=1000", "--aws-zone-type=public"]
#    sources   = var.external_dns_sources
#  }
#
#  depends_on = [module.eks]
#}