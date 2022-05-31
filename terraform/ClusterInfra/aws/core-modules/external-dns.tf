resource "aws_iam_role" "external_dns_oidc" {
  name        = "ExternalDNSUpdatesRole"
  description = "Amazon EKS - ExternalDNS role"

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
              "system:serviceaccount:kube-system:external-dns"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "external_dns_policy" {
  name        = "AllowExternalDNSUpdates"
  description = "Amazon EKS - ExternalDNS role Policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_external_dns_policy" {
  role       = aws_iam_role.external_dns_oidc.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}

locals {
  external_dns_role = "\"eks.amazonaws.com/role-arn\": ${aws_iam_role.external_dns_oidc.arn}"
}

resource "helm_release" "external-dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  namespace        = "dns"
  create_namespace = true
  version          = local.externaldns_version

  values = [
    templatefile("${path.module}/helm-values/external-dns.yaml", {
      iam_role  = local.external_dns_role
      txt_owner = var.external_dns.txt_owner
      prefix    = var.external_dns.prefix
      domains   = indent(2, yamlencode(var.cluster_domains))
      args      = indent(2, yamlencode(concat(var.external_dns.args, [
        "--crd-source-apiversion=externaldns.k8s.io/v1alpha1",
        "--crd-source-kind=DNSEndpoint"
      ])))
      sources   = indent(2, yamlencode(var.external_dns.sources))
    })
  ]
  depends_on = [aws_iam_role.external_dns_oidc, helm_release.kube-prometheus-stack]
}
