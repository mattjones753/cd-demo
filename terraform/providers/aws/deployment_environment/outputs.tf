output "api_gateway_url" {
  value = "${module.hello-world.api_gateway_url}"
}

output "db_url" {
  value = "${module.hello-world.db_url}"
}
