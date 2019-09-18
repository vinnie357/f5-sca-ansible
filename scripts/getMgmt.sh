#!/bin/bash
stackName=${AWS_STACK_NAME}
# aws cloudformation  describe-stacks --stack-name mazza-sca-test-F5BIGIP1-Y70VNOIMPA2W
#aws cloudformation list-exports --query "Exports[?contains(Name, '$stackName')]|[?contains(Name, 'BIGIP1')]|[?contains(Name, 'Management')].[Value]" | jq -r .[][]
stacks=$(aws cloudformation  describe-stacks --query 'Stacks[?contains(StackName, `'$stackName-F5BIGIP'`) == `true`].StackName')
for stack in $stacks
do
    echo "name: $stack"
    if [ [ -z "$stack" ] || [ "$stack" == *'['* ] ];
    then
        continue
    else
        item=$(echo "$stack" | xargs | sed 's/,//' )
        box1=$(aws cloudformation describe-stacks --stack-name $item --query "Stacks[0].Outputs[?OutputKey=='Bigip1ManagementEipAddress'].OutputValue")
        box2=$(aws cloudformation describe-stacks --stack-name $item --query "Stacks[0].Outputs[?OutputKey=='Bigip2ManagementEipAddress'].OutputValue")
        mgmtIp="$box1, $box2"
        echo $mgmtIp
    fi
done