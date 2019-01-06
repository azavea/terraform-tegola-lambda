# terraform-tegola-lambda

A Terraform module to create an Amazon Web Services (AWS) Lambda based [Tegola](https://tegola.io/) vector tile service.

## Usage

```hcl
module "tegola" {
  source = "github.com/azavea/terraform-tegola-lambda?ref=develop"

  function_archive_path   = "${path.module}/../tegola_lambda.zip"
  function_timeout_in_sec = "10"
  function_memory_in_mb   = "128"

  database_hostname = "database.service.tegola.internal"
  database_name     = "tegola"
  database_username = "tegola"
  database_password = "tegola"

  s3_cache_bucket = "tegola-cache"

  vpc_id     = "vpc-20f74844"
  subnet_ids = [...]

  domain_name     = "tegola.azavea.com"
  certificate_arn = "arn:aws:acm..."

  project     = "Something"
  environment = "Staging"
}
```

## Variables

- `vpc_id` - ID of VPC meant to house the Lambda execution environment
- `subnet_ids` - A list of subnet IDs to launch function instances
- `log_group_retention_in_days` - CloudWatch Log group retention period in days (default: `30`)
- `function_archive_path` - Local file system path for Tegola archive (must contain `config.toml`)
- `function_timeout_in_sec` - Function timeout in seconds (default: `10`)
- `function_memory_in_mb` - Function memory in megabytes (default: `128`)
- `s3_cache_bucket` - S3 bucket used for Tegola caching
- `database_hostname` - PostGIS enabled PostgreSQL hostname
- `database_port` - PostgreSQL port (default: `5432`)
- `database_name` - PostgreSQL database name
- `database_username` - PostgreSQL username
- `database_password` - PostgreSQL password
- `certificate_arn` - Amazon Resource Name (ARN) for a TLS certificate to associate with API Gateway
- `domain_name` - Domain name to associate with API Gateway
- `project` - Name of project for Tegola (default: `Unknown`)
- `environment` - Name of environment Tegola is targeting (default: `Unknown`)

## Outputs

- `function_service_role_name` - Function IAM role name
- `function_service_role_arn` - Function IAM role ARN
- `function_security_group_id` - Function security group ID
- `domain_name` - Domain name associated with API Gateway
- `cloudfront_domain_name` - CloudFront distribution domain name associated with API Gateway
- `cloudfront_zone_id`- CloudFront distribution zone ID associated with API Gateway
