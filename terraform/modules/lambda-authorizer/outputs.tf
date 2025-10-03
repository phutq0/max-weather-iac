output "lambda_arn" {
  value       = aws_lambda_function.this.arn
  description = "Lambda authorizer ARN"
}

output "lambda_invoke_arn" {
  value       = aws_lambda_function.this.invoke_arn
  description = "Lambda authorizer invoke ARN"
}

