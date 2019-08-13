#!/usr/bin/bash
revokeLicense() {

# tier3, then tier 1 otherwise tier3 can't phone home
# presents as Unknown exception during ping ://:8080
hosts=$(aws ec2 describe-instances --filters "Name=key-name,Values=mazza-aws,Name=tag:Group,Values=f5group" --query 'Reservations[*].Instances[*].[PublicIpAddress]')
keyfile="~/keys/aws"
command='run util bash && key=$(cat /config/bigip.license | grep "Registration Key" | awk '{ print $4}' ) && yes | tmsh revoke sys license registration-key ${key}'
for host in $hosts
do
    echo $host
    result=$(ssh -t -i $keyfile admin@$host "$command")
    echo $result
done
 

}

deleteBuckets() {

# get buckets
buckets=$(aws s3api list-buckets --query 'Buckets[?contains(Name, `mazza-sca-test`) == `true`].Name')
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
    aws s3api delete-bucket --bucket $bucket --region us-east-1
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

echo "starting"
# license=$(revokeLicense)
# echo $license
echo "deleting buckets"
buckets=$(deleteBuckets)
echo $buckets
echo "deleting stack"
stack=$(deleteStack)
echo $stack

echo "complete"
}


run