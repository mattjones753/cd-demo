# Continuous Delivery Demo

## Application

### Database

### Feature Toggles

## Terraform

## Pipeline

### Concourse

### Deploying concourse config

```bash
fly -t <concourse_team> set-pipeline \
        --pipeline cd-demo \
        --config ci/pipeline.yml \
        --load-vars-from ci/concourse-variables.yml
```

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
```
