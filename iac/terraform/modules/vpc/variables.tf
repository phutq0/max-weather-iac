variable "name" {
  description = "Name prefix for VPC resources"
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of 3 public subnet CIDRs across AZs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of 3 private subnet CIDRs across AZs"
  type        = list(string)
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

