locals {
  cluster_security_group_rules = {
    ingress_nodes_443 = {
      description                = "Node groups to cluster API"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_node_security_group = true
    }
    egress_nodes_443 = {
      description                = "Cluster API to node groups"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "egress"
      source_node_security_group = true
    }
    egress_nodes_kubelet = {
      description                = "Cluster API to node kubelets"
      protocol                   = "tcp"
      from_port                  = 10250
      to_port                    = 10250
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_rules = {
    egress_cluster_443 = {
      description                   = "Node groups to cluster API"
      protocol                      = "tcp"
      from_port                     = 443
      to_port                       = 443
      type                          = "egress"
      source_cluster_security_group = true
    }
    ingress_cluster_443 = {
      description                   = "Cluster API to node groups"
      protocol                      = "tcp"
      from_port                     = 443
      to_port                       = 443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_cluster_kubelet = {
      description                   = "Cluster API to node kubelets"
      protocol                      = "tcp"
      from_port                     = 10250
      to_port                       = 10250
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_self_coredns_tcp = {
      description = "Node to node CoreDNS"
      protocol    = "tcp"
      from_port   = 53
      to_port     = 53
      type        = "ingress"
      self        = true
    }
    egress_self_coredns_tcp = {
      description = "Node to node CoreDNS"
      protocol    = "tcp"
      from_port   = 53
      to_port     = 53
      type        = "egress"
      self        = true
    }
    ingress_self_coredns_udp = {
      description = "Node to node CoreDNS"
      protocol    = "udp"
      from_port   = 53
      to_port     = 53
      type        = "ingress"
      self        = true
    }
    egress_self_coredns_udp = {
      description = "Node to node CoreDNS"
      protocol    = "udp"
      from_port   = 53
      to_port     = 53
      type        = "egress"
      self        = true
    }
    egress_https = {
      description = "Egress all HTTPS to internet"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_ntp_tcp = {
      description = "Egress NTP/TCP to internet"
      protocol    = "tcp"
      from_port   = 123
      to_port     = 123
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_ntp_udp = {
      description = "Egress NTP/UDP to internet"
      protocol    = "udp"
      from_port   = 123
      to_port     = 123
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  node_group_security_group_rules = {
    egress_ntp_tcp = {
      description = "All Traffic Ingress within the cluster"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    #egress_ntp_udp = {
    #  description = "All Traffic Egress"
    #  protocol    = "-1"
    #  from_port   = 0
    #  to_port     = 0
    #  type        = "egress"
    #  cidr_blocks = ["0.0.0.0/0"]
    #}
  }
}

resource "aws_security_group" "control_plane_sg" {
  name        = "control_plane"
  description = "Security Groups for the EKS Cluster"

  vpc_id = module.vpc.vpc_id
  tags   = merge(var.tags, {
    "k8s.io/cluster-autoscaler/enabled"             = "true",
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  })

  depends_on = [module.vpc]
}

resource "aws_security_group" "node_sg" {
  name        = "node"
  description = "Security Groups for the EKS Nodes"

  vpc_id = module.vpc.vpc_id
  tags   = merge(var.tags, {
    "k8s.io/cluster-autoscaler/enabled"             = "true",
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  })

  depends_on = [module.vpc]
}

resource "aws_security_group" "node_group_sg" {
  name        = "node_groups"
  description = "Security Groups for the EKS Node Groups"

  vpc_id = module.vpc.vpc_id
  tags   = merge(var.tags, {
    "k8s.io/cluster-autoscaler/enabled"             = "true",
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  })

  depends_on = [module.vpc]
}

#Control Plane
resource "aws_security_group_rule" "control_plane" {
  for_each          = {for k, v in local.cluster_security_group_rules : k => v}
  type              = each.value.type
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.control_plane_sg.id

  source_security_group_id = aws_security_group.node_sg.id

  depends_on = [aws_security_group.control_plane_sg, aws_security_group.node_sg]
}

#Nodes
resource "aws_security_group_rule" "nodes" {
  for_each                 = {for k, v in local.node_security_group_rules : k => v}
  type                     = each.value.type
  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  security_group_id        = aws_security_group.node_sg.id
  self                     = try(each.value.self, null)
  cidr_blocks              = try(each.value.cidr_blocks, null)
  source_security_group_id = try(
    each.value.source_security_group_id,
    try(each.value.source_cluster_security_group, false) ? aws_security_group.control_plane_sg.id : null
  )

  depends_on = [aws_security_group.control_plane_sg, aws_security_group.node_sg]
}

#Node-Groups
resource "aws_security_group_rule" "node-groups" {
  for_each          = {for k, v in local.node_security_group_rules : k => v}
  type              = each.value.type
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.node_sg.id
  self              = try(each.value.self, null)
  cidr_blocks       = try(each.value.cidr_blocks, null)

  depends_on = [aws_security_group.node_group_sg]
}