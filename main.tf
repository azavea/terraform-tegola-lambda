#
# Security group resources
#
resource "aws_security_group" "tegola" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name        = "sgTegola"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

#
# IAM resources
#
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "tegola" {
  name               = "lambda${var.environment}Tegola"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = "${aws_iam_role.tegola.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_eni_policy" {
  role       = "${aws_iam_role.tegola.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}

#
# CloudWatch resources
#
resource "aws_cloudwatch_log_group" "tegola" {
  name              = "/aws/lambda/func${var.environment}Tegola"
  retention_in_days = "${var.log_group_retention_in_days}"

  tags = {
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

#
# Lambda resources
#
resource "aws_lambda_function" "tegola" {
  filename         = "${var.function_archive_path}"
  source_code_hash = "${base64sha256(file(var.function_archive_path))}"
  function_name    = "func${var.environment}Tegola"
  description      = "Function to execute the Tegola vector tile server."
  role             = "${aws_iam_role.tegola.arn}"
  handler          = "tegola_lambda"
  runtime          = "go1.x"
  timeout          = "${var.function_timeout_in_sec}"
  memory_size      = "${var.function_memory_in_mb}"

  vpc_config {
    subnet_ids         = ["${var.subnet_ids}"]
    security_group_ids = ["${aws_security_group.tegola.id}"]
  }

  environment {
    variables = {
      TEGOLA_CACHE_BUCKET      = "${var.s3_cache_bucket}"
      TEGOLA_DATABASE_HOST     = "${var.database_hostname}"
      TEGOLA_DATABASE_PORT     = "${var.database_port}"
      TEGOLA_DATABASE_NAME     = "${var.database_name}"
      TEGOLA_DATABASE_USER     = "${var.database_username}"
      TEGOLA_DATABASE_PASSWORD = "${var.database_password}"
    }
  }

  tags {
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_lambda_permission" "proxy" {
  statement_id  = "perm${var.environment}TegolaProxy"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.tegola.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.tegola.execution_arn}/*/*"
}

#
# API Gateway resources
#
resource "aws_api_gateway_rest_api" "tegola" {
  name                     = "api${var.environment}Tegola"
  description              = "Tegola vertor tile service."
  minimum_compression_size = 0

  binary_media_types = [
    "*/*",
  ]
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.tegola.id}"
  parent_id   = "${aws_api_gateway_rest_api.tegola.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.tegola.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.tegola.id}"
  resource_id   = "${aws_api_gateway_rest_api.tegola.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "tegola" {
  rest_api_id = "${aws_api_gateway_rest_api.tegola.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  timeout_milliseconds    = 29000
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.tegola.invoke_arn}"
}

resource "aws_api_gateway_integration" "tegola_root" {
  rest_api_id = "${aws_api_gateway_rest_api.tegola.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  timeout_milliseconds    = 29000
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.tegola.invoke_arn}"
}

resource "aws_api_gateway_deployment" "tegola" {
  rest_api_id = "${aws_api_gateway_rest_api.tegola.id}"
  stage_name  = "${lower(var.environment)}"

  depends_on = [
    "aws_api_gateway_integration.tegola",
    "aws_api_gateway_integration.tegola_root",
  ]
}

resource "aws_api_gateway_domain_name" "tegola" {
  certificate_arn = "${var.certificate_arn}"
  domain_name     = "${var.domain_name}"
}

resource "aws_api_gateway_base_path_mapping" "tegola" {
  api_id      = "${aws_api_gateway_rest_api.tegola.id}"
  stage_name  = "${aws_api_gateway_deployment.tegola.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.tegola.domain_name}"
}
