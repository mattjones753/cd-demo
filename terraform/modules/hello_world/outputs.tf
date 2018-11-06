output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.hello_world_api_deployment.invoke_url}"
}

output "db_url" {
  value = "${aws_db_instance.database.endpoint}"
}
