resource "kubernetes_endpoints" "external_endpoints" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      app = var.name
    }
  }

  dynamic "subset" {
    for_each = var.subsets
    content {
      dynamic "address" {
        for_each = subset.value["addresses"]
        content {
          ip = address.value
        }
      }
      dynamic "port" {
        for_each = subset.value["ports"]
        content {
          name     = port.value["name"]
          port     = port.value["port"]
          protocol = port.value["protocol"]
        }
      }
    }
  }
}

resource "kubernetes_service" "external_service" {
  depends_on = [kubernetes_endpoints.external_endpoints]

  for_each = {
    for port in local.ports : "${var.name}.${port.name}" => port
  }

  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      app = var.name
    }
  }

  spec {
    port {
      name        = each.value.name
      port        = each.value.port
      target_port = each.value.port
      protocol    = each.value.protocol
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "external_ingress" {
  depends_on = [kubernetes_service.external_service]
  metadata {
    name      = var.name
    namespace = "external"
    labels = {
      app = var.name
    }
    annotations = {
      "cert-manager.io/cluster-issuer"                      = "letsencrypt-prod"
      "external-dns.alpha.kubernetes.io/target"             = var.domain
      "external-dns.alpha.kubernetes.io/hostname"           = var.domain
      "external-dns.alpha.kubernetes.io/cloudflare-proxied" = "false"
      "nginx.ingress.kubernetes.io/proxy-body-size"         = "10G"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = join(".", [var.domain_prefix, var.domain])
      http {

        dynamic "path" {
          for_each = local.ports
          content {
            path = path.value["path"]
            path_type = "Prefix"
            backend {

              service {
                name = var.name
                port {
                  number = path.value["port"]
                }
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = join("-", [var.name, "cert"])
      hosts       = [join(".", [var.domain_prefix, var.domain])]
    }
  }
}
