# f5-sca-ansible

# based on
# https://docs.ansible.com/ansible/latest/modules/cloudformation_module.html

# get latest sca
git clone https://github.com/mikeoleary/f5-sca-securitystack.git

git clone --branch mazza-bigip-tierx-apps https://github.com/mikeoleary/f5-sca-securitystack.git 

## customize hosts

## build docker image
docker build -t f5-sca-ansible .

##  test run docker image
docker run -t f5-sca-ansible ansible-playbook --version

## run docker image
./ansible_helper ansible-playbook deploy_sca_aws.yaml

# wsl
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "/home/$USER/.docker" -R

# aws cli

## create user for api key in IAM
## capture key id and passphrase
## install aws cli
pip install awscli

## command completion
which aws_completer \
/home/user/.local/bin/aws_completer

complete -C '/home/user/.local/bin/aws_completer' aws

# configure aws cli
aws configure

# pass settings to boto

-e AWS_ACCESS_KEY_ID='yourkeyid' \
-e AWS_SECRET_ACCESS_KEY='yourkey' \

# aws cli tasks
aws cloudformation list-stacks | grep stack-name
aws cloudformation delete-stack --stack-name stack-name

# template testing
aws cloudformation validate-template --template-url https://mustBeS3bucket.com/path/to/json.json

# get your public IPs

aws ec2 describe-instances --filters "Name=key-name,Values=yourkey,Name=tag:Group,Values=f5group" --query 'Reservations[*].Instances[*].[PublicIpAddress]'

example:
aws ec2 describe-instances --filters "Name=key-name,Values=mazza-aws,Name=tag:Group,Values=f5group" --query 'Reservations[*].Instances[*].[PublicIpAddress]'