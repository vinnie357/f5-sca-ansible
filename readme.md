# setup

make setup

make build

make aws


make azure


# needs boto3 botocore

# env script
.env_vars_helper.sh

```bash
#!/bin/bash
# set vars
aws_key_id=$(cat aws/credentials | grep aws_access_key_id | awk '{print $3}' )
aws_key_value=$(cat aws/credentials | grep aws_secret_access_key | awk '{print $3}' )
aws_region="us-east-1"
aws_stack_name="yourstackname-sca-stack"
# export vars
export AWS_ACCESS_KEY_ID=${aws_key_id}
export AWS_SECRET_ACCESS_KEY=${aws_key_value}
export AWS_REGION=${aws_region}
export AWS_STACK_NAME=${aws_stack_name}
# export bigiq vars
export BIGIQ_HOST=""
export BIGIQ_USERNAMENAME=""
export BIGIQ_PASSWORD=""
# export bigip vars
# ansible vault
export ANSIBLE_VAULT_PASSWORD=""
echo "done"
```