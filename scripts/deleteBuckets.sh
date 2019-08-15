#!/usr/bin/bash
# get buckets
buckets=$(aws s3api list-buckets --query 'Buckets[?contains(Name, `mazza-sca-test`) == `true`].Name')
# delete objects in bucket
# aws s3 rm s3://bucket-name --recursive
for bucket in $buckets
do
    aws s3 rm s3://$bucket --recursive
done
# delete bucket
#aws s3api delete-bucket --bucket my-bucket --region us-east-1
for bucket in $buckets
do
    aws s3api delete-bucket --bucket $bucket --region us-east-1
done