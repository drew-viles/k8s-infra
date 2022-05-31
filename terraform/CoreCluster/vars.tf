variable "large_cluster" {
  type        = string
  description = "If a large cluster rook will be used. If not then local storage will be used."
}

variable "cluster_address" {
  type        = string
  description = "Used to denote the address range for MetalLB."
}

variable "add_coredns" {
  type        = bool
  default     = false
  description = "Specifies whether to install coredns - not required for kubeadm."
}

variable "deploy_calico_operator" {
  type        = bool
  default     = false
  description = "Specifies whether to install calico operator"
}

variable "deploy_cluster_autoscaler" {
  type        = bool
  default     = false
  description = "Specifies whether to install the cluster autoscaler"
}