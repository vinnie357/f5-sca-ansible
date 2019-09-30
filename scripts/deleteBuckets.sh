#!/bin/bash
# get buckets
stackName=${AWS_STACK_NAME}
region=${AWS_DEFAULT_REGION}

if [ -z "${stackName}" ];
then
    echo "make sure stack name is set"
    exit 1
else
    buckets=$(aws s3api list-buckets --query 'Buckets[?contains(Name, `'$stackName-f5'`) == `true`].Name'| jq -r .[])
    # delete objects in bucket
    # aws s3 rm s3://bucket-name --recursive
    for bucket in ${buckets[@]}
    do
        echo $bucket
        item=$(echo "$bucket" | xargs | sed 's/,//' )
        aws s3 rm s3://$item --recursive
    done
    # delete bucket
    #aws s3api delete-bucket --bucket my-bucket --region us-east-1
    for bucket in ${buckets[@]}
    do
        echo delete files $bucket
        item=$(echo "$bucket" | xargs | sed 's/,//' )
        aws s3api delete-bucket --bucket $item --region $region
    done
fi