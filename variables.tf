variable "project" {
  default     = "Unknown"
  description = "Name of project for Tegola"
}

variable "environment" {
  default     = "Unknown"
  description = "Name of environment Tegola is targeting"
}

variable "vpc_id" {
  description = "ID of VPC meant to house the Lambda execution environment"
}

variable "subnet_ids" {
  type        = "list"
  description = "A list of subnet IDs to launch function instances"
}

variable "log_group_retention_in_days" {
  default     = "30"
  description = "CloudWatch Log group retention period in days"
}

variable "function_archive_path" {
  description = "Local file system path for Tegola archive"
}

variable "function_timeout_in_sec" {
  default     = "10"
  description = "Function timeout in seconds"
}

variable "function_memory_in_mb" {
  default     = "128"
  description = "Function memory in megabytes"
}

variable "s3_cache_bucket" {
  description = "S3 bucket used for Tegola caching"
}

variable "database_hostname" {
  description = "PostGIS enabled PostgreSQL hostname"
}

variable "database_port" {
  default     = "5432"
  description = "PostgreSQL port"
}

variable "database_name" {
  description = "PostgreSQL database name"
}

variable "database_username" {
  description = "PostgreSQL username"
}

variable "database_password" {
  description = "PostgreSQL password"
}

variable "certificate_arn" {
  description = "Amazon Resource Name for a TLS certificate to associate with API Gateway"
}

variable "domain_name" {
  description = "Domain name to associate with API Gateway"
}
