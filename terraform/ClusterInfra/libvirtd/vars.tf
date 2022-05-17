variable "nodes_private_key" {
  description = "The private key that will be used to connect to the instances"
  type        = string
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