#!/bin/bash
stackName=${AWS_STACK_NAME}


sshKey="/root/.ssh/"${SSH_KEY_NAME}
cat $sshKey > /root/.ssh/key
key="/root/.ssh/key"
chmod 600 $key

tier1=$(`aws cloudformation list-exports --query "Exports[?contains(Name, '$stackName')]|[?contains(Name, 'BIGIP2')]|[?contains(Name, 'Management')].[Value]" | jq -r .[]`)
tier2=$(`aws cloudformation list-exports --query "Exports[?contains(Name, '$stackName')]|[?contains(Name, 'BIGIP1')]|[?contains(Name, 'Management')].[Value]"`| jq -r .[]`)
# find BIG-IP management IP addresses, deprovision internal stacks before external stacks
for ip in ${tier1[@]} ;
do
    echo "revoke license for $ip"
    item=$(echo "$ip" | xargs | sed 's/,//' )
    ssh -i $key -oStrictHostKeyChecking=no admin@"$item" 'modify cli preference pager disabled display-threshold 0; revoke sys license'
done

# deprovision external stack 
for ip in ${tier2[@]};
do
    echo "revoke license for $ip"
    item=$(echo "$ip" | xargs | sed 's/,//' )
    ssh -i $key -oStrictHostKeyChecking=no admin@"$item" 'modify cli preference pager disabled display-threshold 0; revoke sys license'
done
