#!/bin/bash
# aws cloudformation  describe-stacks --stack-name mazza-sca-test-F5BIGIP1-Y70VNOIMPA2W
stacks=$(aws cloudformation  describe-stacks --query 'Stacks[?contains(StackName, `mazza-sca-test-F5BIGIP`) == `true`].StackName')
for stack in $stacks
do
    echo $stack
    box1=$(aws cloudformation describe-stacks --stack-name $stack --query "Stacks[0].Outputs[?OutputKey=='Bigip1ManagementEipAddress'].OutputValue")
    box2=$(aws cloudformation describe-stacks --stack-name $stack --query "Stacks[0].Outputs[?OutputKey=='Bigip2ManagementEipAddress'].OutputValue")
    mgmtIp="$box1, $box2"
    echo $mgmtIp
done