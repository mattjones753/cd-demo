output "api_gateway_url" {
  value = "${aws_api_gateway_stage.hello_world_api_stage.invoke_url}"
}