#!/bin/bash
stackName=${AWS_STACK_NAME}


sshKey="/root/.ssh/"${SSH_KEY_NAME}
cat $sshKey > /root/.ssh/key
key="/root/.ssh/key"
chmod 600 $key
# nested stack resources
# get dynaminc stack names
nestedExternal=$(aws cloudformation list-stack-resources --stack-name $stackName --query "StackResourceSummaries[?contains(LogicalResourceId, 'F5ExternalTier')].PhysicalResourceId[]" --output text | cut -d '/' -f2)
nestedInternal=$(aws cloudformation list-stack-resources --stack-name $stackName --query "StackResourceSummaries[?contains(LogicalResourceId, 'F5InternalTier')].PhysicalResourceId[]" --output text | cut -d '/' -f2)
# get management interfaces by tier
tier1=$(aws cloudformation list-stack-resources --stack-name $nestedExternal --query "StackResourceSummaries[?contains(LogicalResourceId, 'ManagementEipAddress')].PhysicalResourceId[]" | jq -r .[])
tier2=$(aws cloudformation list-stack-resources --stack-name $nestedInternal --query "StackResourceSummaries[?contains(LogicalResourceId, 'ManagementEipAddress')].PhysicalResourceId[]" | jq -r .[])
# exports
#tier1=$(aws cloudformation list-exports --query "Exports[?contains(Name, '$stackName')]|[?contains(Name, 'F5ExternalTier')]|[?contains(Name, 'ManagementEip')].[Value]" | jq -r .[][])
#tier2=$(aws cloudformation list-exports --query "Exports[?contains(Name, '$stackName')]|[?contains(Name, 'F5InternalTier')]|[?contains(Name, 'ManagementEip')].[Value]" | jq -r .[][])
# tier1=$(aws cloudformation list-exports --query "Exports[?contains(Name, '$stackName-F5BIGIP1')]|[?contains(Name, 'ManagementEip')].[Value]"| jq -r .[][])
# tier2=$(aws cloudformation list-exports --query "Exports[?contains(Name, '$stackName-F5BIGIP2')]|[?contains(Name, 'ManagementEip')].[Value]"| jq -r .[][])
# find BIG-IP management IP addresses, deprovision internal stacks before external stacks
for ip in ${tier2[@]} ;
do
    echo "revoke license for $ip"
    item=$(echo "$ip" | xargs | sed 's/,//' )
    ssh -i $key -oStrictHostKeyChecking=no admin@"$item" 'modify cli preference pager disabled display-threshold 0; revoke sys license' 2>/dev/null
done

# deprovision external stack 
for ip in ${tier1[@]};
do
    echo "revoke license for $ip"
    item=$(echo "$ip" | xargs | sed 's/,//' )
    ssh -i $key -oStrictHostKeyChecking=no admin@"$item" 'modify cli preference pager disabled display-threshold 0; revoke sys license' 2>/dev/null
done
