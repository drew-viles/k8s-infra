module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.cidr
  #secondary_cidr_blocks = ["10.1.0.0/16", "10.2.0.0/16"]

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_ipv6                     = var.enable_ipv6
  assign_ipv6_address_on_creation = var.enable_ipv6
  create_egress_only_igw          = true

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  #  public_subnet_ipv6_prefixes  = [0, 1, 2]
  #  private_subnet_ipv6_prefixes = [3, 4, 5]

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }

  tags = merge(var.tags, { "kubernetes.io/cluster/${var.cluster_name}" = "shared" })
}