#data "aws_eks_cluster" "cluster" {
#  name = module.eks.cluster_id
#}
#data "aws_eks_cluster_auth" "cluster" {
#  name = module.eks.cluster_id
#}

provider "aws" {
  region = var.region
}

#provider "kubectl" {
#  host                   = module.eks.cluster_endpoint
#  token                  = data.aws_eks_cluster_auth.cluster.token
#  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#  load_config_file       = false
#  apply_retry_count      = 6
#
#  exec {
#    api_version = "client.authentication.k8s.io/v1alpha1"
#    command     = "aws"
#    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
#    env         = local.aws_auths
#  }
#}
#
#provider "helm" {
#  kubernetes {
#    host                   = module.eks.cluster_endpoint
#    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#
#    exec {
#      api_version = "client.authentication.k8s.io/v1alpha1"
#      command     = "aws"
#      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
#      env         = local.aws_auths
#    }
#  }
#}
#
#provider "kubernetes" {
#  host                   = module.eks.cluster_endpoint
#  token                  = data.aws_eks_cluster_auth.cluster.token
#  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#
#  exec {
#    api_version = "client.authentication.k8s.io/v1alpha1"
#    command     = "aws"
#    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
#    env         = local.aws_auths
#  }
#}
#provider "shell" {}