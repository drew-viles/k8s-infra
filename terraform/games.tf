#Games
resource "kubernetes_namespace_v1" "games" {
  metadata {
    name = "games"
  }
}
#SkyFactory
#resource "kubernetes_persistent_volume_claim_v1" "skyfactory-data" {
#  metadata {
#    name      = "skyfactory-data"
#    namespace = "games"
#    labels = {
#      app = "skyfactory"
#    }
#  }
#  spec {
#    storage_class_name = "fast-disks"
#    access_modes       = ["ReadWriteOnce"]
#    resources {
#      requests = {
#        storage = "10Gi"
#      }
#    }
#  }
#  depends_on = [kubernetes_namespace_v1.games]
#}
#
#resource "kubernetes_service_account_v1" "skyfactory" {
#  metadata {
#    name      = "skyfactory"
#    namespace = "games"
#  }
#  depends_on = [kubernetes_namespace_v1.games]
#}
#
#resource "kubernetes_deployment_v1" "skyfactory" {
#  metadata {
#    name      = "skyfactory"
#    namespace = "games"
#    labels = {
#      app = "skyfactory"
#    }
#  }
#
#  spec {
#    replicas = 1
#
#    selector {
#      match_labels = {
#        app = "skyfactory"
#      }
#    }
#
#    strategy {
#      type = "RollingUpdate"
#      rolling_update {
#        max_unavailable = 1
#        max_surge       = 2
#      }
#    }
#
#    template {
#      metadata {
#        labels = {
#          app = "skyfactory"
#        }
#      }
#
#      spec {
#        service_account_name = "skyfactory"
#        hostname           = "skyfactory"
#
#        security_context{
#          run_as_group = 1000
#          run_as_user = 1000
#        }
#        container {
#          name            = "skyfactory"
#          image           = "goobaroo/skyfactoryone:1.0.4"
#          image_pull_policy = "IfNotPresent"
#
#          #          resources {
#          #            limits   = {
#          #              cpu    = "0.5"
#          #              memory = "512Mi"
#          #            }
#          #            requests = {
#          #              cpu    = "250m"
#          #              memory = "50Mi"
#          #            }
#          #          }
#
#          env {
#            name  = "JVM_OPTS"
#            value = "-Xms2048m -Xmx2048m"
#          }
#          env {
#            name  = "MOTD"
#            value = "Drew's super-amazing-super-awesome super SkyFactory server"
#          }
#
#          #env {
#          #              name = "LEVEL"
#          #              value = "world"
#          #            },
#
#          env {
#            name  = "OPS"
#            value = "DeeToTheVee"
#          }
#          port {
#            name          = "sql"
#            container_port = 25565
#          }
#
#          volume_mount {
#            name      = "data"
#            mount_path = "/data"
#          }
#
#          readiness_probe {
#            tcp_socket {
#              port = 25565
#            }
#
#            initial_delay_seconds = 120
#            timeout_seconds      = 15
#            period_seconds       = 30
#            failure_threshold    = 20
#            success_threshold    = 1
#          }
#
#          liveness_probe  {
#            tcp_socket {
#              port = 25565
#            }
#
#            initial_delay_seconds = 120
#            timeout_seconds      = 15
#            period_seconds       = 15
#            failure_threshold    = 5
#            success_threshold    = 1
#          }
#        }
#
#        volume {
#          name = "data"
#          persistent_volume_claim {
#            claim_name = "skyfactory-data"
#          }
#        }
#      }
#    }
#  }
#}
#
#resource "kubernetes_service_v1" "skyfactory-service-tcp" {
#  metadata {
#    name      = "skyfactory-tcp"
#    namespace = "games"
#    labels = {
#      app = "skyfactory"
#    }
#    annotations = {
#      "external-dns.alpha.kubernetes.io/target": "viles.uk"
#      "external-dns.alpha.kubernetes.io/hostname": "viles.uk"
#      "external-dns.alpha.kubernetes.io/cloudflare-proxied": "false"
#      "metallb.universe.tf/allow-shared-ip": "skyfactory"
#    }
#  }
#  spec {
#    selector = {
#      app = kubernetes_deployment_v1.skyfactory.metadata.0.labels.app
#    }
#    port {
#      name        = "skyfactory-tcp"
#      port        = 25565
#      target_port = 25565
#      protocol    = "TCP"
#    }
#    type = "LoadBalancer"
#  }
#  depends_on = [kubernetes_namespace_v1.games]
#}
#
#resource "kubernetes_service_v1" "skyfactory-service-udp" {
#  metadata {
#    name      = "skyfactory-udp"
#    namespace = "games"
#    labels = {
#      app = "skyfactory"
#    }
#    annotations = {
#      "external-dns.alpha.kubernetes.io/target": "viles.uk"
#      "external-dns.alpha.kubernetes.io/hostname": "viles.uk"
#      "external-dns.alpha.kubernetes.io/cloudflare-proxied": "false"
#      "metallb.universe.tf/allow-shared-ip": "skyfactory"
#    }
#  }
#  spec {
#    selector = {
#      app = kubernetes_deployment_v1.skyfactory.metadata.0.labels.app
#    }
#    port {
#      name        = "skyfactory-udp"
#      port        = 25565
#      target_port = 25565
#      protocol    = "UDP"
#    }
#    type = "LoadBalancer"
#  }
#  depends_on = [kubernetes_namespace_v1.games]
#}
