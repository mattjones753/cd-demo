# cd-demo

## Pipeline

```bash
fly -t example set-pipeline \
    --pipeline my-pipeline \
    --config pipeline.yml \
    --var "aws_deploy_account=<account id>" \
    --var "aws_deploy_role=<role arn>"
```
