#!/usr/bin/bash
revokeLicense() {

stackName="mazza-sca-test"
sshKey="~/keys/aws"

# find BIG-IP management IP addresses, deprovision internal stacks before external stacks
for ip in `aws cloudformation list-exports --query "Exports[?contains(Name, '$stackName')]|[?contains(Name, 'F5InternalTier')]|[?contains(Name, 'Management')].[Value]"`;
do
    echo "revoke license for $ip"
    ssh -i $sshKey -oStrictHostKeyChecking=no admin@"$ip" 'modify cli preference pager disabled display-threshold 0; revoke sys license'
done

# deprovision external stack 
for ip in `aws cloudformation list-exports --query "Exports[?contains(Name, '$stackName')]|[?contains(Name, 'F5ExternalTier')]|[?contains(Name, 'Management')].[Value]"`;
do
    echo "revoke license for $ip"
    ssh -i $sshKey -oStrictHostKeyChecking=no admin@"$ip" 'modify cli preference pager disabled display-threshold 0; revoke sys license'
done


# run again when failed
# hosts=$(aws ec2 describe-instances --filters "Name=key-name,Values=mazza-aws,Name=tag:Group,Values=f5group" --query 'Reservations[*].Instances[*].[PublicIpAddress]')
# for ip in $hosts
# do
#     echo "revoke license for $ip"
#     ssh -i $sshKey -oStrictHostKeyChecking=no admin@"$ip" 'modify cli preference pager disabled display-threshold 0; revoke sys license'
# done
# should see:
# Data Input Error: An operational license is required.
# if the license has been revoked successfully

# # tier3, then tier 1 otherwise tier3 can't phone home
# # presents as Unknown exception during ping ://:8080
# hosts=$(aws ec2 describe-instances --filters "Name=key-name,Values=mazza-aws,Name=tag:Group,Values=f5group" --query 'Reservations[*].Instances[*].[PublicIpAddress]')
# keyfile="~/keys/aws"
# command='modify cli preference pager disabled display-threshold 0; revoke sys license'
# for host in $hosts
# do
#     echo $host
#     result=$(ssh -t -i $keyfile -oStrictHostKeyChecking=no admin@$host "$command")
#     echo $result
# done
 

}

deleteBuckets() {
stackName=${AWS_STACK_NAME}
region=${AWS_DEFAULT_REGION}
# get buckets
buckets=$(aws s3api list-buckets --query 'Buckets[?contains(Name, `'$stackName-f5'`) == `true`].Name'| jq -r .[])
# delete objects in bucket
# aws s3 rm s3://bucket-name --recursive
for bucket in $buckets
do
    echo $bucket
    aws s3 rm s3://$bucket --recursive
done
# delete bucket
#aws s3api delete-bucket --bucket my-bucket --region us-east-1
for bucket in $buckets
do
    echo delete files $bucket
    aws s3api delete-bucket --bucket $bucket --region $region
done

}

deleteStack() {

docker build -t f5-sca-ansible .
keyid=$(cat aws/credentials | grep aws_access_key_id | awk '{ print $3}' )
key=$(cat aws/credentials | grep aws_secret_access_key | awk '{ print $3}' )
docker run --rm -it \
  -v ~/.ssh:/root/.ssh \
  -v $(pwd):/ansible \
  -v $(pwd)/aws/:/home/.aws/:ro \
  -e AWS_ACCESS_KEY_ID=${keyid} \
  -e AWS_SECRET_ACCESS_KEY=${key} \
  f5-sca-ansible ansible-playbook delete_sca_aws.yaml 

}

run () {

echo "starting" `date`
start_time="$(date -u +%s)"
license=$(revokeLicense)
echo $license
read -p 'Press [Enter] key to continue...'
echo "deleting buckets"
buckets=$(deleteBuckets)
echo $buckets
echo "deleting stack"
stack=$(deleteStack)
echo $stack

echo "complete" `date`
end_time="$(date -u +%s)"
elapsed="$((($end_time-$start_time)/60))"
echo "minutes elapsed: $elapsed"

}


run