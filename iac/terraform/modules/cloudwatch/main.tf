terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11"
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
  tags                  = var.tags
  is_production         = lower(var.environment) == "production"
  retention_in_days_app = local.is_production ? 30 : 7
  app_log_group_name    = coalesce(var.application_log_group_name, "${var.log_group_prefix}/${var.cluster_name}/applications")
}

resource "aws_cloudwatch_log_group" "applications" {
  name              = local.app_log_group_name
  retention_in_days = local.retention_in_days_app
  tags              = local.tags
}

resource "aws_sns_topic" "alerts" {
  name = "${var.cluster_name}-alerts"
  tags = local.tags
}

resource "aws_sns_topic_subscription" "emails" {
  count     = length(var.sns_email_subscriptions)
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email_subscriptions[count.index]
}

data "aws_iam_policy_document" "fluent_bit_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.fluent_bit_namespace}:aws-for-fluent-bit"]
    }
  }
}

resource "aws_iam_role" "fluent_bit" {
  name               = "${var.cluster_name}-fluent-bit"
  assume_role_policy = data.aws_iam_policy_document.fluent_bit_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "fluent_bit" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "fluent_bit" {
  name   = "${var.cluster_name}-fluent-bit"
  policy = data.aws_iam_policy_document.fluent_bit.json
}

resource "aws_iam_role_policy_attachment" "fluent_bit" {
  role       = aws_iam_role.fluent_bit.name
  policy_arn = aws_iam_policy.fluent_bit.arn
}

# Temporarily disabled due to network connectivity issues
# resource "helm_release" "fluent_bit" {
#   name             = "aws-for-fluent-bit"
#   repository       = "https://aws.github.io/eks-charts"
#   chart            = "aws-for-fluent-bit"
#   namespace        = var.fluent_bit_namespace
#   create_namespace = true
#   wait             = false
#   timeout          = 300

#   values = [yamlencode({
#     serviceAccount = {
#       create      = true
#       name        = "aws-for-fluent-bit"
#       annotations = { "eks.amazonaws.com/role-arn" = aws_iam_role.fluent_bit.arn }
#     }
#     cloudWatch = {
#       logGroupName     = aws_cloudwatch_log_group.applications.name
#       logRetentionDays = local.retention_in_days_app
#     }
#   })]
# }

# Temporarily disabled due to network connectivity issues
# resource "helm_release" "cloudwatch_agent" {
#   name             = "cloudwatch-agent"
#   repository       = "https://aws.github.io/eks-charts"
#   chart            = "aws-for-fluent-bit"
#   namespace        = var.cloudwatch_agent_namespace
#   create_namespace = true
#   wait             = false
#   timeout          = 300

#   values = [yamlencode({
#     clusterName = var.cluster_name
#   })]
# }

# Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.alarms_enabled ? 1 : 0
  alarm_name          = "${var.cluster_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "High CPU utilization"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = var.alarms_enabled ? 1 : 0
  alarm_name          = "${var.cluster_name}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "High memory utilization"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "pod_restarts" {
  count               = var.alarms_enabled ? 1 : 0
  alarm_name          = "${var.cluster_name}-pod-restarts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = var.pod_restart_metric_name
  namespace           = var.pod_restart_metric_namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Pod restart rate high"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions          = var.pod_restart_metric_dimensions
}

resource "aws_cloudwatch_metric_alarm" "api_latency" {
  count               = var.alarms_enabled ? 1 : 0
  alarm_name          = "${var.cluster_name}-api-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = var.custom_latency_metric_name
  namespace           = var.custom_latency_metric_namespace
  period              = 60
  statistic           = "Average"
  threshold           = 1000
  alarm_description   = "API response time high"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions          = var.custom_latency_metric_dimensions
}

