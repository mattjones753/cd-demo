variable "aws_region" {
  description = "the AWS region to deploy infrastructure in"
  default = "eu-west-1"
}

variable "aws_account_id" {
  description = "The account to build the AWS infrastructure in"
}

variable "aws_deployment_role_arn" {
  default = ""
  description = "The IAM role to use when executing deployment"
}

variable "artifact_directory" {
  description = "where the go artifacts can be found"
  default = "../bin/"
}