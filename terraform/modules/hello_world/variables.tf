variable "aws_region" {
  description = "the AWS region to deploy infrastructure in"
}

variable "aws_account_id" {
  description = "The account to build the AWS infrastructure in"
}

variable "aws_deployment_role_arn" {
  description = "The IAM role to use when executing deployment"
}

variable "artifact_directory" {
  description = "where the go artifacts can be found"
}

variable "aws_vpc_id" {
  description = "the id of the AWS VPC we are deploying into"
}

variable "db_pass" {
  description = "the password for the RDS instance"
}