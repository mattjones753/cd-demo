locals {
  path_to_lambda_artifact = "${var.artifact_directory}/hello_world.zip"
}

resource "aws_api_gateway_rest_api" "hello_world_api" {
  name        = "hello_world_api"
  description = "Hello World API"
}

resource "aws_api_gateway_resource" "hello_world_api_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.hello_world_api.root_resource_id}"
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello_world_api_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.hello_world_api.id}"
  resource_id   = "${aws_api_gateway_resource.hello_world_api_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_world_api_integration" {
  http_method = "${aws_api_gateway_method.hello_world_api_method.http_method}"
  resource_id = "${aws_api_gateway_resource.hello_world_api_resource.id}"
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

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.hello_world_api.id}/*/${aws_api_gateway_method.hello_world_api_method.http_method}${aws_api_gateway_resource.hello_world_api_resource.path}"
}

resource "aws_lambda_function" "lambda" {
  filename         = "${local.path_to_lambda_artifact}"
  function_name    = "hello_world"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "hello_world"
  runtime          = "go1.x"
  source_code_hash = "${base64sha256(file(local.path_to_lambda_artifact))}"

  environment {
    variables = {
      DATABASE_ENDPOINT = "${aws_db_instance.database.endpoint}"
      DATABASE_USER     = "${aws_db_instance.database.username}"
      DATABASE_PASSWORD = "${aws_db_instance.database.password}"
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

//data "aws_iam_policy_document" "lambda_policy_doc" {
//  statement {
//    actions = ["sts:AssumeRole"]
//    effect  = "Allow"
//
//    resources = []
//
//    principals {
//      type        = "Service"
//      identifiers = ["lambda.amazonaws.com"]
//    }
//  }
//}

resource "aws_iam_role" "lambda_role" {
  name = "hello_world_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_db_instance" "database" {
  allocated_storage   = 10
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "10.4"
  instance_class      = "db.t2.micro"
  name                = "postgres_db"
  username            = "dbadmin"
  password            = "rubbishpassword"
  skip_final_snapshot = "true"
}