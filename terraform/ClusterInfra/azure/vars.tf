variable "use_aks" {
  description = "Whether to use a managed Control Plane from Microsoft (AKS)"
  type        = bool
  default     = false
}

variable "number_of_control_plane_nodes" {
  description = "Number of Control Plane nodes to deploy"
  type        = number
  default     = 3
}

variable "number_of_worker_nodes" {
  description = "Number ofWorker nodes to deploy"
  type        = number
  default     = 1
}

variable "number_of_etcd_nodes" {
  description = "Number of ETCD nodes to deploy"
  type        = number
  default     = 3
}