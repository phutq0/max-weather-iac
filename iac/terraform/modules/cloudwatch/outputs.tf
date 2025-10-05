output "application_log_group_name" {
  value       = aws_cloudwatch_log_group.applications.name
  description = "Application log group name"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "SNS topic ARN for alerts"
}

output "fluent_bit_role_arn" {
  value       = aws_iam_role.fluent_bit.arn
  description = "FluentBit IAM role ARN for CloudWatch logs"
}

