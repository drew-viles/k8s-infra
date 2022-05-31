#Calico - for pod routing
resource "helm_release" "calico" {
  count            = var.deploy_calico_operator ?1 : 0
  name             = "calico"
  repository       = "https://projectcalico.docs.tigera.io/charts"
  chart            = "tigera-operator"
  namespace        = "calico-system"
  create_namespace = true
  version          = local.calico_version

  values = [
    file("${path.module}/helm-values/coredns.yaml")
  ]
}

#Cluster autoscaling
resource "helm_release" "cluster_autosclaer" {
  count            = var.deploy_cluster_autoscaler ?1 : 0
  name             = "cluster_autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster_autoscaler"
  namespace        = "kube-system"
  create_namespace = true
  version          = local.cluster_autoscaler_version

  values = [
    file("${path.module}/helm-values/cluster_autoscaler.yaml")
  ]
}

#Rook - only required on large clusters
resource "helm_release" "rook-ceph-operator" {
  count            = (var.large_cluster) ? 1 : 0
  name             = "rook-ceph"
  repository       = "https://charts.rook.io/release"
  chart            = "rook-ceph"
  namespace        = "rook-ceph"
  create_namespace = true
  version          = local.rook_version

  values = [
    file("${path.module}/helm-values/rook-operator.yaml")
  ]
}

resource "helm_release" "rook-ceph-cluster" {
  count            = (var.large_cluster) ? 1 : 0
  name             = "rook-ceph-cluster"
  repository       = "https://charts.rook.io/release"
  chart            = "rook-ceph-cluster"
  namespace        = "rook-ceph"
  create_namespace = true
  version          = local.rook_version

  values = [
    file("${path.module}/helm-values/rook.yaml")
  ]
  depends_on = [helm_release.rook-ceph-operator]
}

#data "kubectl_path_documents" "calico-docs" {
#  pattern = "${path.module}/manifests/calico/*.yaml"
#}
#
#resource "kubectl_manifest" "calico-manifests" {
#  depends_on = [data.kubectl_path_documents.calico-docs]
#  for_each  = toset(data.kubectl_path_documents.calico-docs.documents)
#  yaml_body = each.value
#}

resource "helm_release" "coredns" {
  count            = var.add_coredns ?1 : 0
  name             = "coredns"
  repository       = "https://coredns.github.io/helm"
  chart            = "coredns"
  namespace        = "kube-system"
  create_namespace = false
  version          = local.coredns_version

  values = [
    file("${path.module}/helm-values/coredns.yaml")
  ]
  depends_on = [helm_release.calico]
}

#Local Storage - Only required on small clusters
resource "helm_release" "local-storage-provisioner" {
  count            = (!var.large_cluster) ? 1 : 0
  name             = "local-storage-provisioner"
  repository       = "https://drew-viles.github.io/helm-charts"
  chart            = "provisioner"
  namespace        = "storage"
  create_namespace = true
  version          = local.local_storage_provisioner_version

  values = [
    file("${path.module}/helm-values/local-storage.yaml")
  ]
  depends_on = [helm_release.calico]
}

## MetalLB
resource "helm_release" "metallb" {
  name             = "metallb"
  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  namespace        = "metallb"
  create_namespace = true
  version          = local.metallb_version

  values = [
    templatefile("${path.module}/helm-values/metallb.yaml", { address_range = var.cluster_address })
  ]
  depends_on = [helm_release.calico]
}

# Cert Manager
resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = local.certmanager_version

  values = [
    file("${path.module}/helm-values/cert-manager.yaml")
  ]
  depends_on = [helm_release.calico]
}

# Cert Manager - Secret, Issuers
data "kubectl_path_documents" "cert-manager-issuers-docs" {
  pattern = "${path.module}/manifests/cert-manager/*.yaml"
}

resource "kubectl_manifest" "cert-manager-issuers-manifests" {
  depends_on = [helm_release.cert-manager]
  for_each   = toset(data.kubectl_path_documents.cert-manager-issuers-docs.documents)
  yaml_body  = each.value
}

# ExternalDNS
resource "helm_release" "external-dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  namespace        = "dns"
  create_namespace = true
  version          = local.externaldns_version

  values = [
    file("${path.module}/helm-values/external-dns.yaml")
  ]
  depends_on = [helm_release.calico]
}

## Kube-Prometheus-Stack
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
  depends_on = [helm_release.calico]
}

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
  depends_on = [helm_release.calico]
}

## ECK
resource "helm_release" "eck" {
  name             = "eck"
  repository       = "https://helm.elastic.co"
  chart            = "eck-operator"
  namespace        = "elastic"
  create_namespace = true
  version          = local.elastic_cloud_version

  values = [
    file("${path.module}/helm-values/eck-operator.yaml")
  ]
  depends_on = [helm_release.calico]
}


## Jaeger
#resource "helm_release" "jaeger-operator" {
#  name             = "jaeger-operator"
#  repository       = "https://jaegertracing.github.io/helm-charts"
#  chart            = "jaeger-operator"
#  namespace        = "tracing"
#  create_namespace = true
#  version          = local.jaeger_operator_version
#
#  values = [
#    file("${path.module}/helm-values/jaeger-operator.yaml")
#  ]
#  depends_on = [helm_release.calico]
#}

## Open Telemetry
#resource "helm_release" "open-telemetry-collector" {
#  name             = "open-telemetry-collector"
#  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
#  chart            = "open-telemetry-collector"
#  namespace        = "tracing"
#  create_namespace = true
#  version          = local.open_telemetry_collector_version
#
#  values = [
#    file("${path.module}/helm-values/open-telemetry-collector.yaml")
#  ]
#  depends_on = [helm_release.calico]
#}

#resource "helm_release" "open-telemetry-operator" {
#  name             = "open-telemetry-operator"
#  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
#  chart            = "opentelemetry-operator"
#  namespace        = "tracing"
#  create_namespace = false
#  version          = local.open_telemetry_operator_version
#
#  values = [
#    file("${path.module}/helm-values/open-telemetry-operator.yaml")
#  ]
#  depends_on = [helm_release.calico]
#}

## Nginx Ingress
resource "helm_release" "nginx-ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "public-ingress"
  create_namespace = true
  version          = local.nginx_version

  values = [
    file("${path.module}/helm-values/nginx.yaml")
  ]
  depends_on = [helm_release.calico]
}

## Sealed Secrets
resource "helm_release" "sealed-secrets" {
  name             = "sealed-secrets"
  repository       = "https://bitnami-labs.github.io/sealed-secrets"
  chart            = "sealed-secrets"
  namespace        = "secret-system"
  create_namespace = true
  version          = local.sealed_secrets_version

  values = [
    file("${path.module}/helm-values/sealed-secrets.yaml")
  ]
  depends_on = [helm_release.calico]
}