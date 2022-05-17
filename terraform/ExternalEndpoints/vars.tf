variable "name" {
  type        = string
  description = "The name that will be applied to the Endpoint, Service and Ingress"
}
variable "namespace" {
  type        = string
  description = "The namespace that the resource will be deployed to"
}

variable "subsets" {
  type = list(object({
    addresses = list(string)
    ports = set(object({
      name     = string
      port     = number
      protocol = string
      path = string
    }))
  }))
  description = "A list of IP Addresses that the Endpoint will point to."
}

variable "requires_ssl" {
  type        = bool
  description = "Require CertManager to generate an SSL for this endpoint."
}

variable "domain_prefix" {
  type        = string
  description = "The domain prefix is prepended onto the domain for the ingress."
}

variable "domain" {
  type        = string
  description = "The domain that is associated with this endpoint."
}