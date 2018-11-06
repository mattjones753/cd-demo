locals {
  path_to_lambda_artifact = "${var.artifact_directory}/hello_world.zip"
}

resource "aws_api_gateway_rest_api" "hello_world_api" {
  name        = "hello_world_api"
  description = "Hello World API"
}

resource "aws_api_gateway_resource" "hello_world_root_api_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.hello_world_api.root_resource_id}"
  path_part   = "hello"
}

resource "aws_api_gateway_resource" "injector_api_proxy_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
  parent_id   = "${aws_api_gateway_resource.hello_world_root_api_resource.id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "hello_world_api_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.hello_world_api.id}"
  resource_id   = "${aws_api_gateway_resource.injector_api_proxy_resource.id}"
  http_method   = "GET"
  authorization = "NONE"

  request_parameters {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "hello_world_api_integration" {
  http_method = "${aws_api_gateway_method.hello_world_api_method.http_method}"
  resource_id = "${aws_api_gateway_resource.injector_api_proxy_resource.id}"
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"

  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.hello_world_api.id}/*/${aws_api_gateway_method.hello_world_api_method.http_method}${aws_api_gateway_resource.injector_api_proxy_resource.path}"
}

resource "aws_lambda_function" "lambda" {
  filename         = "${local.path_to_lambda_artifact}"
  function_name    = "hello_world"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "hello_world"
  runtime          = "go1.x"
  source_code_hash = "${base64sha256(file(local.path_to_lambda_artifact))}"

  vpc_config {
    security_group_ids = ["${aws_security_group.allow_all.id}"]
    subnet_ids         = ["${data.aws_subnet_ids.vpc_subnets.ids}"]
  }

  environment {
    variables = {
      DATABASE_ENDPOINT         = "${aws_db_instance.database.endpoint}"
      DATABASE_USER             = "${aws_db_instance.database.username}"
      DATABASE_PASSWORD         = "${aws_db_instance.database.password}"
      DATABASE_NAME             = "${aws_db_instance.database.name}"
      ENABLE_BIRTHDAY_COUNTDOWN = "false"
    }
  }
}

resource "aws_api_gateway_deployment" "hello_world_api_deployment" {
  depends_on = ["aws_api_gateway_integration.hello_world_api_integration"]

  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
  stage_name  = "release"

  variables = {
    "answer" = "42"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "hello_world_lambda_role"

  assume_role_policy = "${data.aws_iam_policy_document.lambda_role_policy.json}"
}

data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
      "ec2:DeleteNetworkInterface",
    ]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }

    effect = "Allow"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_all"
  }
}

data "aws_subnet_ids" "vpc_subnets" {
  vpc_id = "${var.aws_vpc_id}"
}

resource "aws_db_subnet_group" "default" {
  name        = "main_subnet_group"
  description = "Our main group of subnets"
  subnet_ids  = ["${data.aws_subnet_ids.vpc_subnets.ids}"]
}

resource "aws_db_instance" "database" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "10.4"
  instance_class         = "db.t2.micro"
  name                   = "postgres_db"
  username               = "dbadmin"
  password               = "rubbishpassword"
  skip_final_snapshot    = "true"
  publicly_accessible    = "false"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"
  apply_immediately      = "true"
}
