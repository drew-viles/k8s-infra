#Websites
resource "kubernetes_namespace_v1" "websites" {
  metadata {
    name = "websites"
  }
}
##Elisa's CampNat20 yo!
#resource "kubernetes_persistent_volume_claim_v1" "campnat20" {
#  metadata {
#    name      = "campnat20-data"
#    namespace = "websites"
#    labels = {
#      app = "campnat20"
#    }
#  }
#  spec {
#    storage_class_name = "fast-disks"
#    access_modes       = ["ReadWriteOnce"]
#    resources {
#      requests = {
#        storage = "2Gi"
#      }
#    }
#  }
#  depends_on = [kubernetes_namespace_v1.websites]
#}
#
#resource "kubernetes_service_account_v1" "campnat20" {
#  metadata {
#    name      = "campnat20"
#    namespace = "websites"
#  }
#  depends_on = [kubernetes_namespace_v1.websites]
#}
#
#resource "kubernetes_config_map_v1" "campnat20-nginx"{
#  metadata {
#    name      = "campnat20"
#    namespace = "websites"
#    labels = {
#      app = "campnat20"
#    }
#  }
#  data = {
#    "default.conf" = file("${path.module}/configs/campnat20/default.conf")
#  }
#}
#
#resource "kubernetes_deployment_v1" "campnat20" {
#  metadata {
#    name      = "campnat20"
#    namespace = "websites"
#    labels = {
#      app = "campnat20"
#    }
#  }
#
#  spec {
#    replicas = 1
#
#    selector {
#      match_labels = {
#        app = "campnat20"
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
#          app = "campnat20"
#        }
#      }
#
#      spec {
#        service_account_name = "campnat20"
#        hostname           = "campnat20"
#
##        security_context{
##          run_as_group = 1000
##          run_as_user = 1000
##        }
#        container {
#          name            = "nginx"
#          image           = "nginx:1.21.5-alpine"
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
#          port {
#            name          = "http"
#            container_port = 80
#          }
#
#          volume_mount {
#            name      = "www"
#            mount_path = "/var/www"
#          }
#
#          volume_mount {
#            name      = "config"
#            mount_path = "/etc/nginx/conf.d/"
#          }
#
#          readiness_probe {
#            tcp_socket {
#              port = 80
#            }
#
#            initial_delay_seconds = 10
#            timeout_seconds      = 15
#            period_seconds       = 30
#            failure_threshold    = 20
#            success_threshold    = 1
#          }
#
#          liveness_probe  {
#            tcp_socket {
#              port = 80
#            }
#
#            initial_delay_seconds = 10
#            timeout_seconds      = 15
#            period_seconds       = 15
#            failure_threshold    = 5
#            success_threshold    = 1
#          }
#        }
#        container {
#          name            = "php"
#          image           = "worldofelisa/laravel-php:8.0-fpm"
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
#          port {
#            name          = "fpm"
#            container_port = 9000
#          }
#
#          volume_mount {
#            name      = "www"
#            mount_path = "/var/www"
#          }
#
#          readiness_probe {
#            tcp_socket {
#              port = 9000
#            }
#
#            initial_delay_seconds = 10
#            timeout_seconds      = 15
#            period_seconds       = 30
#            failure_threshold    = 20
#            success_threshold    = 1
#          }
#
#          liveness_probe  {
#            tcp_socket {
#              port = 9000
#            }
#
#            initial_delay_seconds = 10
#            timeout_seconds      = 15
#            period_seconds       = 15
#            failure_threshold    = 5
#            success_threshold    = 1
#          }
#        }
#
#        volume {
#          name = "www"
#          persistent_volume_claim {
#            claim_name = "campnat20-data"
#          }
#        }
#
#        volume {
#          name = "config"
#          config_map {
#            name = "campnat20"
#            items {
#              key = "default.conf"
#              path = "default.conf"
#            }
#          }
#        }
#      }
#    }
#  }
#  depends_on = [kubernetes_namespace_v1.websites]
#}
#
#resource "kubernetes_service_v1" "campnat20" {
#  metadata {
#    name      = "campnat20-http"
#    namespace = "websites"
#    labels = {
#      app = "campnat20"
#    }
#  }
#  spec {
#    selector = {
#      app = kubernetes_deployment_v1.campnat20.metadata.0.labels.app
#    }
#    port {
#      name        = "http"
#      port        = 80
#      target_port = "http"
#      protocol    = "TCP"
#    }
#    type = "ClusterIP"
#  }
#  depends_on = [kubernetes_namespace_v1.websites]
#}
#
#resource "kubernetes_ingress_v1" "example" {
#  metadata {
#    name = "campnat20"
#    namespace = "websites"
#    annotations = {
#      "cert-manager.io/cluster-issuer": "letsencrypt-prod"
#      "ingress.kubernetes.io/rewrite-target": "/"
#    }
#  }
#
#  spec {
#    ingress_class_name = "nginx"
#    rule {
#      host = "campnat20.com"
#      http {
#        path {
#          backend {
#            service {
#              name = "campnat20-http"
#              port {
#                number = 80
#              }
#            }
#          }
#
#          path = "/"
#          path_type = "Prefix"
#        }
#      }
#    }
#
#    tls {
#      secret_name = "campnat20-cert"
#      hosts = [
#        "campnat20.com"
#      ]
#    }
#  }
#}