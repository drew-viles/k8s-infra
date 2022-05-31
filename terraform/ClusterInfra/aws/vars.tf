variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "credentials_file" {
  type = string
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "cluster_domains" {
  type = list(string)
}

variable "cert_manager" {
  type = object({
    email          = string
    ingress_class  = string
    hosted_zone_id = string
  })
}

variable "external_dns_sources" {
  type    = list(string)
  default = ["service", "ingress"]
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.small", "t3.medium"]
}

variable "loadbalancer_type" {
  type        = string
  description = "Denotes which Ingress controller to use"
  validation {
    condition     = (var.loadbalancer_type == "nginx" || var.loadbalancer_type == "alb" || var.loadbalancer_type == "none")
    error_message = "Please enter a valid loadbalancer type. Valid options are alb, nginx, none."
  }
}

variable "disk_size" {
  type    = number
  default = 25
}

variable "enable_ipv6" {
  type = bool
}

variable "cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "authenticated_aws_users" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}

variable "tags" {
  type = map(string)
}