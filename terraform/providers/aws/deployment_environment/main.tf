terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "= 1.15.0"

  assume_role {
    role_arn = "${var.aws_deployment_role_arn}"
  }
}

module "hello-world" {
  source = "../../../modules/hello_world"

  aws_region              = "${var.aws_region}"
  aws_account_id          = "${var.aws_account_id}"
  aws_deployment_role_arn = "${var.aws_deployment_role_arn}"
  artifact_directory      = "${var.artifact_directory}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  db_pass                 = "${var.db_pass}"
}
