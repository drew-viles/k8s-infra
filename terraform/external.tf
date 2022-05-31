resource "kubernetes_namespace" "external_endpoints" {
  metadata {
    name = "external"
  }
}

# External Endpoints
module "owncloud-endpoint" {
  source  = "./ExternalEndpoints"
  name    = "owncloud"
  namespace = kubernetes_namespace.external_endpoints.metadata[0].name
  subsets = [
    {
      addresses = ["192.168.0.94"]
      ports     = [
        {
          name     = "http"
          port     = 80
          protocol = "TCP"
          path     = "/"
        }
      ]
    }
  ]

  requires_ssl  = true
  domain_prefix = "cloud"
  domain        = "viles.uk"
}
module "plex-endpoint" {
  source  = "./ExternalEndpoints"
  name    = "plex"
  namespace = kubernetes_namespace.external_endpoints.metadata[0].name
  subsets = [
    {
      addresses = ["192.168.0.92"]
      ports     = [
        {
          name     = "http"
          port     = 32400
          protocol = "TCP"
          path     = "/"
        }
      ]
    }
  ]

  requires_ssl  = true
  domain_prefix = "plex"
  domain        = "viles.uk"
}