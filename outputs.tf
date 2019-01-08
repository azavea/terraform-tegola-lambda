output "function_service_role_name" {
  value = "${aws_iam_role.tegola.name}"
}

output "function_service_role_arn" {
  value       = "${aws_iam_role.tegola.arn}"
  description = "Function IAM role name"
}

output "function_security_group_id" {
  value       = "${aws_security_group.tegola.id}"
  description = "Function IAM role ARN"
}

output "domain_name" {
  value       = "${aws_api_gateway_domain_name.tegola.domain_name}"
  description = "Domain name associated with API Gateway"
}

output "cloudfront_domain_name" {
  value       = "${aws_api_gateway_domain_name.tegola.cloudfront_domain_name}"
  description = "CloudFront distribution domain name associated with API Gateway"
}

output "cloudfront_zone_id" {
  value       = "${aws_api_gateway_domain_name.tegola.cloudfront_zone_id}"
  description = "CloudFront distribution zone ID associated with API Gateway"
}
