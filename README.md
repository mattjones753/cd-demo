# Continuous Delivery Demo
This repository contains some simple code to help demonstrate some continuous delivery techniques as part of a talk.

## Application
The application itself is a simple hello world style application that is written in Go, and packaged as a lambda to be deployed in AWS infrastructure behind and AWS API Gateway.
It has a simple database that will contain the users and any call to `/hello/<name>` where name matches a user in the database will respond with 'Hello, name' 
### Database
The app contains a database, which is defined using flyway database migrations under the `db` directory

### Feature Toggles
To demonstrate the use of feature toggles an environmnet variable, `ENABLE_BIRTHDAY_COUNTDOWN` can be set to true to show the number of days till the user's birthday if it is stored in the database
You'll be able to enable the feature toggle by manually updating the environment variable value in the AWS lambda console for the `hello_world` lambda.
Whilst this isn't necessarily the idea way to manage a feature toggle, it is a simple way to demonstrate how it can be done!

## Terraform
The terraform code contains all the necessary configuration to produce the AWS infrastructure to run this application.
This includes the lambda, the database, the API Gateway as well as the necessary networking and permissions to get them to all work together.
## Pipeline
The preferred way of applying any changes to this repository would be to create a continuous delivery pipeline.
This project contains a concourse pipeline configuration file that builds a simple pipeline that will build and deploy the application, infrastructure and database migrations in this repository

### Concourse
This does assume you have a concourse instance or cluster already setup.
It assumes that the concourse setup has access to deploy AWS infrastructure necessary by assuming an IAM role (see below for more details).

### Deploying concourse config

To create the pipeline, you'll need to have your concourse instance setup and be logged in to a team that the pipeline will be run on.

To create the pipeline, you'll need to set some variables in a file `ci/concourse-variables.yml` as follows

```yaml
# optional role for executing terraform
aws_deployment_role: arn:aws:iam::123456789012:role/deploy_role
# aws region we are deploying to>"
aws_region: eu-west-1
# aws account id we will be executing terraform against>"
aws_account_id: 123456789012
# s3 bucket name where terraform will story state>"
terraform_backend_bucket: s3-bucket-for-terraform-state
# object prefix/name for terraform's state file>"
terraform_backend_key: path/to/terraform.tfstate
# s3 bucket where lambda artifacts are to be stored>"
artifact_s3_bucket: artifact-s3-bucket-name
# s3 prefix for lambda artifacts
artifact_s3_key_prefix: artifacts/prefix
# VPC id to deploy the database and lambdas to
vpc_id: '["subnet-1-id","subnet-2-id"]'
```

then you can run the following `fly` command, replacing `<concourse_team>` with your concourse team name.
```bash
fly -t <concourse_team> set-pipeline \
        --pipeline cd-demo \
        --config ci/pipeline.yml \
        --load-vars-from ci/concourse-variables.yml
```