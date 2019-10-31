# User setup
## Configure your enviroment choices in ansible:
```bash
├── host_vars
│   └── sca-aws
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

## Azure credentials
Azure Active Directory
App registrations
get api keys for:
- Application (client) ID
  - client secret
- Directory (tenant) ID
- Subscription ID
- 
## env vars script for docker
Set your vars and create the script

```bash
cat > .env_vars_helper.sh <<EOF
#!/bin/bash
# set vars
# aws
aws_key_id=$(cat aws/credentials | grep aws_access_key_id | awk '{print $3}' )
aws_key_value=$(cat aws/credentials | grep aws_secret_access_key | awk '{print $3}' )
aws_region="us-east-1"
aws_stack_name="yourstackname-sca-stack"
ssh_key_dir="$(echo $HOME)/.ssh"
aws_ssh_key_name="id_rsa"
azure_ssh_key_name="id_rsa"
# azure
arm_client_id="yourid"
arm_client_secret="yoursecret"
arm_subscription_id="yoursub"
arm_tenant_id="yourtentantid"
arm_resource_group="yoursca-name-rg"
# export vars
# aws
export SSH_KEY_DIR=${ssh_key_dir}
export AWS_SSH_KEY_NAME=${aws_ssh_key_name}
export AZURE_SSH_KEY_NAME=${azure_ssh_key_name}
export AWS_ACCESS_KEY_ID=${aws_key_id}
export AWS_SECRET_ACCESS_KEY=${aws_key_value}
export AWS_REGION=${aws_region}
export AWS_STACK_NAME=${aws_stack_name}
# azure
export ARM_CLIENT_ID=${arm_client_id}
export ARM_CLIENT_SECRET=${arm_client_secret}
export ARM_SUBSCRIPTION_ID=${arm_subscription_id}
export ARM_TENANT_ID=${arm_tenant_id}
export ARM_RESOURCE_GROUP=${arm_resource_group}
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
- . ./.env_vars_helper.sh 
- make aws
## azure:
- . ./.env_vars_helper.sh 
- make azure
## to do:
shrink docker images
add options for tiers in azure
gcp?
