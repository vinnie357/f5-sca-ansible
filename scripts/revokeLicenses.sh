#!/bin/bash
stackName=${AWS_STACK_NAME}

stackName="mazza-sca-test"
sshKey="~/keys/aws"

# find BIG-IP management IP addresses, deprovision internal stacks before external stacks
for ip in `aws cloudformation list-exports --query "Exports[?contains(Name, '$stackName')]|[?contains(Name, 'BIGIP2')]|[?contains(Name, 'Management')].[Value]"`;
do
    echo "revoke license for $ip"
    ssh -i $sshKey -oStrictHostKeyChecking=no admin@"$ip" 'modify cli preference pager disabled display-threshold 0; revoke sys license'
done

# deprovision external stack 
for ip in `aws cloudformation list-exports --query "Exports[?contains(Name, '$stackName')]|[?contains(Name, 'BIGIP1')]|[?contains(Name, 'Management')].[Value]"`;
do
    echo "revoke license for $ip"
    ssh -i $sshKey -oStrictHostKeyChecking=no admin@"$ip" 'modify cli preference pager disabled display-threshold 0; revoke sys license'
done
