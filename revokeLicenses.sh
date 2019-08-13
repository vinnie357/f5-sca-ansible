#!/usr/bin/bash
# tier3, then tier 1 otherwise tier3 can't phone home
# presents as Unknown exception during ping ://:8080
hosts=$(aws ec2 describe-instances --filters "Name=key-name,Values=mazza-aws,Name=tag:Group,Values=f5group" --query 'Reservations[*].Instances[*].[PublicIpAddress]')
keyfile="~/keys/aws"
command='run util bash && key=$(cat /config/bigip.license | grep "Registration Key" | awk '{ print $4}' ) && yes | tmsh revoke sys license registration-key ${key}'
for host in $hosts
do
    result=$(ssh -t -i $keyfile admin@$host "$command")
    echo $result
done
