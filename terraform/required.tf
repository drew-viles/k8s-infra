terraform {
  required_version = ">= 1.0.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }

    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}