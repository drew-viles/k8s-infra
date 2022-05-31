terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
  }
}