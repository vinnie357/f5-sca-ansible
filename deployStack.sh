deploy () {

docker build -t f5-sca-ansible .
keyid=$(cat aws/credentials | grep aws_access_key_id | awk '{ print $3}' )
key=$(cat aws/credentials | grep aws_secret_access_key | awk '{ print $3}' )
docker run --rm -it \
  -v ~/.ssh:/root/.ssh \
  -v $(pwd):/ansible \
  -v $(pwd)/aws/:/home/.aws/:ro \
  -e AWS_ACCESS_KEY_ID=${keyid} \
  -e AWS_SECRET_ACCESS_KEY=${key} \
  f5-sca-ansible ansible-playbook deploy_sca_aws.yaml

}

getPass () {
stackName=${AWS_STACK_NAME}
buckets=$(aws s3api list-buckets --query "[Buckets][*][?contains(Name, '$stackName-f5')].[Name]" | jq -r .[][][])
for bucket in $buckets
do
    echo $bucket
    cred=$(aws s3 cp s3://$bucket/credentials/master - | head)
    echo $cred
done

}

getMgmt () {
stackName=${AWS_STACK_NAME}
stacks=$(aws cloudformation  describe-stacks --query 'Stacks[?contains(StackName, `'$stackName-F5'`) == `true`].StackName' | jq -r .[])
for stack in $stacks
do
    echo $stack
    box1=$(aws cloudformation describe-stacks --stack-name $stack --query "Stacks[0].Outputs[?OutputKey=='Bigip1ManagementEipAddress'].OutputValue")
    box2=$(aws cloudformation describe-stacks --stack-name $stack --query "Stacks[0].Outputs[?OutputKey=='Bigip2ManagementEipAddress'].OutputValue")
    mgmtIp="$box1, $box2"
    echo $mgmtIp
done

}

# updateSrc () {

# #git clone https://github.com/mikeoleary/f5-sca-securitystack.git --branch mazza-bigip-tierx-apps
# echo "updating src files"
# src=$(pwd)
# mkdir -p f5-sca-securitystack
# cd f5-sca-securitystack
# echo $(pwd)
# git pull https://github.com/mikeoleary/f5-sca-securitystack.git mazza-bigip-tierx-apps
# cd $src
# echo "done"

# }

run () {

echo "starting:" `date`
start_time="$(date -u +%s)"
# echo "update src files"
# updateSrcResult=$(updateSrc)
# echo $updateSrcResult
echo "starting Deployment"
deployResult=$(deploy)
echo $deployResult
echo "get web pass"
getPassResult=$(getPass)
echo $getPassResult
echo "get mgmt ips"
getMgmtResult=$(getMgmt)
echo $getMgmtResult
end_time="$(date -u +%s)"
elapsed="$((($end_time-$start_time)/60))"
echo "complete:" `date`
echo "minutes elapsed: $elapsed"
}

run