terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  tags = merge({ Name = var.name }, var.tags)
}

data "aws_iam_policy_document" "oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:*:*"]
    }
  }
}

resource "aws_security_group" "cluster" {
  name        = "${var.name}-cluster-sg"
  description = "EKS Cluster security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { "kubernetes.io/cluster/${var.name}" = "owned" })
}

resource "aws_security_group" "nodes" {
  name        = "${var.name}-nodes-sg"
  description = "EKS Nodes security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Nodes to nodes all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Cluster to nodes"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { "kubernetes.io/cluster/${var.name}" = "owned" })
}

resource "aws_iam_role" "cluster" {
  name = "${var.name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "nodes" {
  name = "${var.name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "nodes_worker" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "nodes_cni" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "nodes_ecr" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = [aws_security_group.cluster.id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = local.tags
}
# Kubernetes provider configured to talk to the new EKS cluster
provider "kubernetes" {
  host                   = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}


resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  tags            = local.tags
}

data "tls_certificate" "oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# Spot Node Group
resource "aws_eks_node_group" "spot" {
  count           = var.enable_spot_node_group ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-spot"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.spot_node_desired_size
    min_size     = var.spot_node_min_size
    max_size     = var.spot_node_max_size
  }

  instance_types = var.spot_node_instance_types

  # Spot instance configuration
  capacity_type = "SPOT"

  update_config {
    max_unavailable = 1
  }

  tags       = local.tags
  depends_on = [aws_iam_role_policy_attachment.nodes_worker, aws_iam_role_policy_attachment.nodes_cni, aws_iam_role_policy_attachment.nodes_ecr]
}

# On-Demand Node Group
resource "aws_eks_node_group" "ondemand" {
  count           = var.enable_ondemand_node_group ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-ondemand"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.ondemand_node_desired_size
    min_size     = var.ondemand_node_min_size
    max_size     = var.ondemand_node_max_size
  }

  instance_types = var.ondemand_node_instance_types

  # On-demand instance configuration
  capacity_type = "ON_DEMAND"

  update_config {
    max_unavailable = 1
  }

  tags       = local.tags
  depends_on = [aws_iam_role_policy_attachment.nodes_worker, aws_iam_role_policy_attachment.nodes_cni, aws_iam_role_policy_attachment.nodes_ecr]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
}
# -----------------------------------------------------------------------------
# aws-auth ConfigMap (optional) — coexists with access entries
# -----------------------------------------------------------------------------
locals {
  aws_auth_map_users_yaml = length(var.aws_auth_map_users) > 0 ? yamlencode(var.aws_auth_map_users) : null
  aws_auth_map_roles_yaml = length(var.aws_auth_map_roles) > 0 ? yamlencode(var.aws_auth_map_roles) : null
}

resource "kubernetes_config_map_v1" "aws_auth" {
  count = length(var.aws_auth_map_users) > 0 || length(var.aws_auth_map_roles) > 0 ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = merge(
    var.aws_auth_map_users != [] ? { mapUsers = yamlencode(var.aws_auth_map_users) } : {},
    var.aws_auth_map_roles != [] ? { mapRoles = yamlencode(var.aws_auth_map_roles) } : {}
  )
}


# -----------------------------------------------------------------------------
# EKS Access Entries (optional)
# -----------------------------------------------------------------------------
resource "aws_eks_access_entry" "this" {
  for_each     = { for e in var.access_entries : e.principal_arn => e }
  cluster_name = aws_eks_cluster.this.name
  principal_arn = each.value.principal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "this" {
  for_each     = { for e in var.access_entries : e.principal_arn => e }
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope_type
    namespaces = try(each.value.namespaces, null)
  }

  depends_on = [aws_eks_access_entry.this]
}

resource "aws_iam_role" "ebs_csi" {
  count = var.enable_ebs_csi_driver ? 1 : 0
  name  = "${var.name}-ebs-csi-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRoleWithWebIdentity"
      Effect    = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.this.arn
      }
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  count      = var.enable_ebs_csi_driver ? 1 : 0
  role       = aws_iam_role.ebs_csi[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi" {
  count                   = var.enable_ebs_csi_driver ? 1 : 0
  cluster_name            = aws_eks_cluster.this.name
  addon_name              = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi[0].arn
  depends_on              = [aws_iam_role_policy_attachment.ebs_csi]
}

