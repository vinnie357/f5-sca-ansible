#!/bin/bash
#mazza-sca-test
#f5-sca-mazza
#for key in `aws s3api list-objects --bucket $BUCKET --prefix bucket/path/to/files/ | jq -r '.Contents[].Key'`
# do
#   echo $key
#   aws s3 cp s3://$BUCKET/$key - | md5sum
# done

#!/bin/bash
buckets=$(aws s3api list-buckets --query 'Buckets[?contains(Name, `mazza-sca-test`) == `true`].Name')
for bucket in $buckets
do
    echo $bucket
    cred=$(aws s3 cp s3://$bucket/credentials/master - | head)
    echo $cred
    # grep -Po '"text":.*?[^\\]",' tweets.json
    # echo "$line" | grep -o select
    #user=$($cred | jq 'username')
    #user=$(echo "$cred" | grep -Po '"username":.*?[^\\]",')
    #echo $user
    # pass=$($cred | jq 'password')
    #pass=$(echo "$cred" | grep -Po '"password":.*?[^\\]",')
    #echo $pass
done