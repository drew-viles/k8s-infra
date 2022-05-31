locals {
  redis_version         = "16.9.1"
  postgres_version      = "12.9.0"
  k8ssandra_operator_version      = "0.37.3"
  cass_operator_version      = "0.35.3"
  harbor_version        = "1.9.0"
  gitea_version         = "5.0.7"
  drone_version         = "2.7.2"
  drone_secrets_version = "0.1.1"
  drone_runner_version  = "0.1.0"

  large_cluster          = false
  main_cluster_addresses = "192.168.0.100-192.168.0.149"
  nuc_addresses          = "192.168.0.150-192.168.0.169"
}