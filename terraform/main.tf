#module "cluster-infra" {
#  source = "./ClusterInfra"
#  cloud = "none"
#  kubernetes_version = "1.22"
#}

# Core Cluster Resources
module "core-cluster" {
  source                 = "./CoreCluster"
  large_cluster          = local.large_cluster
  cluster_address        = local.nuc_addresses
  deploy_calico_operator = true
}

# Redis
resource "helm_release" "redis" {
  name             = "redis"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "redis"
  namespace        = "cache"
  create_namespace = true
  version          = local.redis_version

  values = [
    file("${path.module}/helm-values/redis.yaml")
  ]

  depends_on = [module.core-cluster]
}

# Postgres
resource "helm_release" "postgres" {
  name             = "postgres"
  repository       = "https://drew-viles.github.io/helm-charts"
  chart            = "postgresql"
  namespace        = "database"
  create_namespace = true
  version          = local.postgres_version

  values = [
    file("${path.module}/helm-values/postgres.yaml")
  ]

  depends_on = [module.core-cluster]
}

#K8ssandra
#resource "helm_release" "k8ssandra" {
#  name       = "k8ssandra"
#  repository = "https://helm.k8ssandra.io/stable"
#  chart      = "k8ssandra-operator"
#  namespace  = "database"
#  create_namespace = false
#  version    = local.k8ssandra_operator_version
#
#  values = [
#    file("${path.module}/helm-values/k8ssandra-operator.yaml")
#  ]
#}
#
#resource "helm_release" "cass" {
#  name       = "cass"
#  repository = "https://helm.k8ssandra.io/stable"
#  chart      = "cass-operator"
#  namespace  = "database"
#  create_namespace = false
#  version    = local.cass_operator_version
#
#  values = [
#    file("${path.module}/helm-values/cass-operator.yaml")
#  ]
#}

# Harbor
resource "helm_release" "harbor" {
  name             = "harbor"
  repository       = "https://helm.goharbor.io"
  chart            = "harbor"
  namespace        = "harbor"
  create_namespace = true
  version          = local.harbor_version

  values = [
    file("${path.module}/helm-values/harbor.yaml")
  ]

  depends_on = [module.core-cluster]
}

# Gitea
resource "kubernetes_namespace_v1" "gitea" {
  metadata {
    annotations = {
      name = "gitea"
    }

    labels = {
      app = "gitea"
    }

    name = "gitea"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "gitea-data" {
  metadata {
    name      = "gitea-data"
    namespace = "gitea"
    labels    = {
      app = "gitea"
    }
  }
  spec {
    storage_class_name = "fast-disks"
    #    volume_mode = "Filesystem"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }

  depends_on = [kubernetes_namespace_v1.gitea]
}

resource "helm_release" "gitea" {
  name             = "gitea"
  repository       = "https://dl.gitea.io/charts/"
  chart            = "gitea"
  namespace        = "gitea"
  create_namespace = false
  version          = local.gitea_version

  values = [
    file("${path.module}/helm-values/gitea.yaml")
  ]

  depends_on = [kubernetes_namespace_v1.gitea]
}

##Drone
resource "helm_release" "drone" {
  name       = "drone"
  repository = "https://drew-viles.github.io/helm-charts"
  chart      = "drone"
  namespace  = "gitea"
  version    = local.drone_version
  create_namespace = false
  values = [
    file("${path.module}/helm-values/drone.yaml")
  ]
}


#Drone Secrets - manifests
data "kubectl_path_documents" "drone-docs" {
  pattern = "${path.module}/manifests/drone-secrets/*.yaml"
}

resource "kubectl_manifest" "drone-manifests" {
  for_each  = toset(data.kubectl_path_documents.drone-docs.documents)
  yaml_body = each.value
}

#Drone Secrets
resource "helm_release" "drone-secrets" {
  depends_on = [kubectl_manifest.drone-manifests]
  name       = "drone-secrets"
  repository = "https://charts.drone.io"
  chart      = "drone-kubernetes-secrets"
  namespace  = "gitea"
  create_namespace = false
  version    = local.drone_secrets_version

  values = [
    file("${path.module}/helm-values/drone-secrets.yaml")
  ]

}

#Drone Runner
resource "helm_release" "drone-runner" {
  depends_on = [helm_release.drone]
  name       = "drone-runner"
  repository = "https://drew-viles.github.io/helm-charts"
  chart      = "drone-runner-kube"
  namespace  = "gitea"
  create_namespace = false
  version    = local.drone_runner_version

  values = [
    file("${path.module}/helm-values/drone-runner.yaml")
  ]

}


## Games are loaded from games.tf


## Websites are loaded from websites.tf
