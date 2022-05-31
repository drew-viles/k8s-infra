module "cluster_role" {
  source           = "./modules/iam_role"
  role_name        = "eksClusterRole"
  role_description = "Amazon EKS - Cluster role"
  service          = "eks.amazonaws.com"
  attach_to        = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}

#resource "aws_iam_role_policy_attachment" "attach_vpc_policy" {
#  role       = aws_iam_role.cluster_role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#}

module "node_role" {
  source           = "./modules/iam_role"
  role_name        = "eksNodeRole"
  role_description = "Amazon EKS - Node role"
  service          = "ec2.amazonaws.com"
  attach_to        = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}