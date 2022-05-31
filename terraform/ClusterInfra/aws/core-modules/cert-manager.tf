resource "aws_iam_role" "cert_manager_oidc" {
  name        = "CertManagerDNSUpdatesRole"
  description = "Amazon EKS - CertManager role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : var.oidc_arn
        },
        "Condition" : {
          "StringEquals" : {
            "${var.oidc_host}:sub" : [
              "system:serviceaccount:cert-manager:cert-manager"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cert_manager_policy" {
  name        = "AllowCertManagerDNSUpdates"
  description = "Amazon EKS - CertManager role Policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "route53:GetChange",
        "Resource" : "arn:aws:route53:::change/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : "arn:aws:route53:::hostedzone/${var.certmanager.hosted_zone_id}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_cert_manager_policy" {
  role       = aws_iam_role.cert_manager_oidc.name
  policy_arn = aws_iam_policy.cert_manager_policy.arn
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
  depends_on = [helm_release.kube-prometheus-stack]
}

resource "kubectl_manifest" "cert-manager-prod-issuer" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata   = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server              = "https://acme-v02.api.letsencrypt.org/directory"
        email               = var.certmanager.email
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region = var.region
                role   = "arn:aws:iam::${var.aws_account_id}:role/CertManagerDNSUpdatesRole"
              }
            }
          }
        ]
      }
    }
  })
  depends_on = [helm_release.cert-manager]
}

resource "kubectl_manifest" "cert-manager-staging-issuer" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata   = {
      name = "letsencrypt-staging"
    }
    spec = {
      acme = {
        server              = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email               = var.certmanager.email
        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }
        solvers = [
          {
            selector = {
              dnsZones = var.cluster_domains
            }
            dns01 = {
              route53 = {
                region = var.region
                role   = "arn:aws:iam::${var.aws_account_id}:role/CertManagerDNSUpdatesRole"
              }
            }
          }
        ]
      }
    }
  })
  depends_on = [helm_release.cert-manager]
}