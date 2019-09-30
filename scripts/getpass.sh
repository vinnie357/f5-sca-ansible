#!/bin/bash
stackName=${AWS_STACK_NAME}
#buckets=$(aws s3api list-buckets --query 'Buckets[?contains(Name, `mazza-sca-test`) == `true`].Name')
buckets=$(aws s3api list-buckets --query "[Buckets][*][?contains(Name, '$stackName-f5')].[Name]" | jq -r .[][][])
for bucket in $buckets
do
    echo $bucket
    item=$(echo "$bucket" | xargs | sed 's/,//' )
    cred=$(aws s3 cp s3://$item/credentials/master - | head)
    echo $cred
done