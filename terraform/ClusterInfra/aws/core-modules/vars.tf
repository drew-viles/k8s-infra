variable "cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "cluster_domains" {
  type        = list(string)
  description = "Cluster domain names"
}
variable "loadbalancer_type" {
  type        = string
  description = "Denotes which Ingress controller to use"
  validation {
    condition     = (var.loadbalancer_type == "nginx" || var.loadbalancer_type == "alb" || var.loadbalancer_type == "none")
    error_message = "Please enter a valid loadbalancer type. Valid options are alb, nginx, none."
  }
}

variable "certmanager" {
  description = "Cert Manager configuration settings"
  type        = object({
    email          = string
    ingress_class  = string
    hosted_zone_id = string
  })
  default = {
    email          = null
    ingress_class  = "nginx"
    hosted_zone_id = null
  }

}

variable "external_dns" {
  description = "External DNS configuration settings"
  type        = object({
    txt_owner = string
    prefix    = string
    args      = list(string)
    sources   = list(string)
  })
  default = {
    txt_owner = null
    prefix    = null
    args      = []
    sources   = []
  }
}

variable "oidc_host" {
  type        = string
  description = "OIDC host"
}

variable "oidc_arn" {
  type        = string
  description = "OIDC ARN"
}