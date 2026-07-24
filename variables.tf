variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR Block"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "key_name" {
  description = "AWS EC2 Key Pair Name"
  type        = string
}

variable "bucket_name" {
  description = "S3 Bucket for Terraform Backend"
  type        = string
}

variable "dynamodb_table" {
  description = "DynamoDB Table for Terraform State Lock"
  type        = string
}