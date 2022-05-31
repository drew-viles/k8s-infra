## Kube-Prometheus-Stack
resource "helm_release" "kube-prometheus-stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = local.prometheus_stack_version

  values = [
    file("${path.module}/helm-values/kube-prometheus-stack.yaml")
  ]
}

## Metrics Server
resource "helm_release" "metrics-server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  namespace        = "monitoring"
  create_namespace = true
  version          = local.metrics_server_version

  values = [
    file("${path.module}/helm-values/metrics-server.yaml")
  ]
  depends_on = [helm_release.kube-prometheus-stack]
}


## Sealed Secrets
#resource "helm_release" "sealed-secrets" {
#  name             = "sealed-secrets"
#  repository       = "https://bitnami-labs.github.io/sealed-secrets"
#  chart            = "sealed-secrets"
#  namespace        = "secret-system"
#  create_namespace = true
#  version          = local.sealed_secrets_version
#
#  values = [
#    file("${path.module}/helm-values/sealed-secrets.yaml")
#  ]
#}