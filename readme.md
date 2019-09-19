# User setup
## Configure your enviroment choices in ansible:
```bash
├── host_vars
│   └── sca-01
│       ├── vars.yaml
│       └── vault.yaml
```

## AWS credentials
Set IAM access key in aws

set your key values for the script:

create credentials file for aws:
```bash
cat > aws/credentials <<EOF
aws_access_key_id = XXXXXXXXXXXXXX
aws_secret_access_key = X1X1xxXxx1xxX0xxxxxxX
EOF
```

## env vars script for docker
Set your vars and create the script

```bash
cat > .env_vars_helper.sh <<EOF
#!/bin/bash
# set vars
aws_key_id=$(cat aws/credentials | grep aws_access_key_id | awk '{print $3}' )
aws_key_value=$(cat aws/credentials | grep aws_secret_access_key | awk '{print $3}' )
aws_region="us-east-1"
aws_stack_name="yourstackname-sca-stack"
ssh_key_dir="$(echo $HOME)/.ssh"
ssh_key_name="id_rsa"
# export vars
export SSH_KEY_DIR=${ssh_key_dir}
export SSH_KEY_NAME=${ssh_key_name}
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
EOF
```

# running:

## aws:
. ./.env_vars_helper.sh
make aws

## azure:
make azure

## to do:
make azure
