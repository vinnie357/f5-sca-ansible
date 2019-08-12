#!/usr/bin/bash
# update with your key or filters https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html
list=$(aws ec2 describe-instances --filters "Name=key-name,Values=mazza-aws,Name=tag:Group,Values=f5group" --query 'Reservations[*].Instances[*].[PublicIpAddress]')
for host in $list
do
    cmd.exe /c start wsl.exe ssh -i ~/keys/aws admin@$host
done