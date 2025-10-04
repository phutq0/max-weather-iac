output "lambda_arn" {
  value       = aws_lambda_function.this.arn
  description = "Lambda authorizer ARN"
}

output "lambda_invoke_arn" {
  value       = aws_lambda_function.this.invoke_arn
  description = "Lambda authorizer invoke ARN"
}

output "lambda_function_name" {
  value       = aws_lambda_function.this.function_name
  description = "Lambda function name"
}

