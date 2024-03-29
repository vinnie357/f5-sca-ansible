#!/bin/bash
stackName=${AWS_STACK_NAME}
# aws cloudformation  describe-stacks --stack-name mazza-sca-test-F5BIGIP1-Y70VNOIMPA2W
#aws cloudformation list-exports --query "Exports[?contains(Name, '$stackName')]|[?contains(Name, 'BIGIP1')]|[?contains(Name, 'Management')].[Value]" | jq -r .[][]
stacks=$(aws cloudformation  describe-stacks --query 'Stacks[?contains(StackName, `'$stackName-F5'`) == `true`].StackName' | jq -r .[])
for stack in $stacks
do
    echo "name: $stack"
    if [ -z "${stack}" ];
    then
        echo "make sure stack name is set"
        exit 1
    else
        item=$(echo "$stack" | xargs | sed 's/,//' )
        #resources
        box1=$(aws cloudformation list-stack-resources --stack-name $item --query "StackResourceSummaries[?contains(LogicalResourceId, 'Bigip1ManagementEipAddress')].PhysicalResourceId[]" | jq -r .[])
        box2=$(aws cloudformation list-stack-resources --stack-name $item --query "StackResourceSummaries[?contains(LogicalResourceId, 'Bigip2ManagementEipAddress')].PhysicalResourceId[]" | jq -r .[])
        #outputs
        # box1=$(aws cloudformation describe-stacks --stack-name $item --query "Stacks[0].Outputs[?OutputKey=='Bigip1ManagementEipAddress'].OutputValue")
        # box2=$(aws cloudformation describe-stacks --stack-name $item --query "Stacks[0].Outputs[?OutputKey=='Bigip2ManagementEipAddress'].OutputValue")
        mgmtIp="$box1, $box2"
        echo $mgmtIp
    fi
done