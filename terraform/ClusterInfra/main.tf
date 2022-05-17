module "aws" {
  count  = var.cloud == "aws"? 1 : 0
  source = "./aws"

}

module "google" {
  count  = var.cloud == "google"? 1 : 0
  source = "./google"

}

module "azure" {
  count  = var.cloud == "azure"? 1 : 0
  source = "./azure"

}

module "libvirtd" {
  count  = var.cloud == "none"? 1 : 0
  source = "./libvirtd"
  nodes_private_key = "abcde"
}