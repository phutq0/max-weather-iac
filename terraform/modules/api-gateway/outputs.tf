output "rest_api_id" {
  value       = aws_api_gateway_rest_api.this.id
  description = "REST API ID"
}

output "stage_invoke_urls" {
  value       = { for k, s in aws_api_gateway_stage.this : k => "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${s.stage_name}" }
  description = "Stage invoke URLs"
}

output "api_key_value" {
  value       = aws_api_gateway_api_key.this.value
  description = "API key value"
  sensitive   = true
}

