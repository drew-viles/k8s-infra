cluster_name     = "edb-eks"
cluster_version  = "1.22"
region           = "us-east-1"
aws_profile      = "default"
account_id       = "060066518084"
credentials_file = <<EOF
[default]
region=us-east-1
output=json
EOF


cidr = "10.0.0.0/16"

private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

enable_ipv6 = false

tags = {}

authenticated_aws_users = [
  #  {
  #    userarn  = "arn:aws:iam::66666666666:user/user2"
  #    username = "user2"
  #    groups   = ["system:masters"]
  #  }
]

cluster_domains = ["cmcloudlab657.info"]

cert_manager = {
  hosted_zone_id = "Z06988981AXGT7O3OLBIY"
  email          = "drew@hudson-viles.uk"
  ingress_class  = "alb"
}

loadbalancer_type = "alb"