variable "kubernetes_version" {
  description = "The Kubernetes Version to use"
  type        = string
  default     = "1.22"
}

variable "cloud" {
  Description = "Which cloud to use (or none)"
  type        = bool
  default     = "none"
  validation {
    condition     = var.cloud == "none" || var.cloud == "aws" || var.cloud == "google" || var.cloud == "azure"
    error_message = "Please enter a valid cloud. None will resume Libvirtd."
  }
}
