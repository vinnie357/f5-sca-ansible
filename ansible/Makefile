.PHONY: build test deploy aws azure

export DIR = $(shell pwd)

default: setup build test

aws: setup build testaws deployAWS creds

azure: setup build testazure deployAzure

build: 
	docker build --build-arg AWS_REGION=${AWS_REGION} -t f5-sca-ansible-dev .

deployAWS:
	@echo "starting:" `date`
	@start_time="$(date -u +%s)"
	@docker run -it \
	--volume ${DIR}/roles:/etc/ansible/roles \
	--volume ${DIR}/playbooks:/etc/ansible/playbooks \
	--volume ${DIR}/scripts:/etc/ansible/scripts \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	f5-sca-ansible-dev \
	bash -c "ansible-playbook playbooks/deploy_sca_aws.yaml"
	@end_time="$(date -u +%s)"
	@elapsed="$((($end_time-$start_time)/60))"
	@echo "complete:" `date`
	@echo "minutes elapsed: ${elapsed}"

deployAzure:
	@echo "starting:" `date`
	@start_time="$(date -u +%s)"
	@docker run -it \
	--volume ${DIR}/roles:/etc/ansible/roles \
	--volume ${DIR}/playbooks:/etc/ansible/playbooks \
	--volume ${DIR}/scripts:/etc/ansible/scripts \
	-e ARM_RESOURCE_GROUP=${ARM_RESOURCE_GROUP} \
	-e ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e ARM_TENANT_ID=${ARM_TENANT_ID} \
	-e ARM_CLIENT_ID=${ARM_CLIENT_ID} \
	-e ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} \
	-e AZURE_CLIENT_ID=${ARM_CLIENT_ID} \
	-e AZURE_SECRET=${ARM_CLIENT_SECRET} \
	-e AZURE_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e AZURE_TENANT=${ARM_TENANT_ID} \
	f5-sca-ansible-dev \
	bash -c "ansible-playbook playbooks/deploy_sca_azure.yaml"
	@end_time="$(date -u +%s)"
	@elapsed="$((($end_time-$start_time)/60))"
	@echo "complete:" `date`
	@echo "minutes elapsed: ${elapsed}"

pipelineAWS: build deployPipelineAWS

deployPipelineAWS:
	@echo "deploy pipeline"
	@docker run -it \
	--volume ${DIR}/roles:/etc/ansible/roles \
	--volume ${DIR}/playbooks:/etc/ansible/playbooks \
	--volume ${DIR}/scripts:/etc/ansible/scripts \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	f5-sca-ansible-dev \
	bash -c "ansible-playbook playbooks/deploy_sca_aws_pipeline.yaml"

destroyPipelineAWS:
	@echo "destroy pipeline"
	@docker run --rm -it \
	--volume ${DIR}/roles:/etc/ansible/roles \
	--volume ${DIR}/playbooks:/etc/ansible/playbooks \
	--volume ${DIR}/scripts:/etc/ansible/scripts \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	f5-sca-ansible-dev \
	bash -c "ansible-playbook playbooks/delete_sca_aws_pipeline.yaml"


setup:
	@echo "make vault keys"
	@echo "configure aws creds"
	#./.env_vars_helper.sh
	@echo "deploy pipeline"

creds:
	@echo "get credentials"
	@docker run -it \
	--volume ${DIR}/roles:/etc/ansible/roles \
	--volume ${DIR}/playbooks:/etc/ansible/playbooks \
	--volume ${DIR}/scripts:/etc/ansible/scripts \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_STACK_NAME=${AWS_STACK_NAME} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	f5-sca-ansible-dev \
	bash -c "/etc/ansible/scripts/getpass.sh;\
	/etc/ansible/scripts/getMgmt.sh"

connect:
	#run docker get list
	#print list
	#connect to list
	@docker run -it \
	--volume ${DIR}/roles:/etc/ansible/roles \
	--volume ${DIR}/playbooks:/etc/ansible/playbooks \
	--volume ${DIR}/scripts:/etc/ansible/scripts \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_STACK_NAME=${AWS_STACK_NAME} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	f5-sca-ansible-dev \
	bash -c "/etc/ansible/scripts/connect.sh"

destroyAWS: build revokelicense deletebuckets deletestack

delete: deletebuckets deletestack

revoke: revokelicense

revokelicense:
	@echo "revoke license"
	@docker run -it \
	--volume ${DIR}/roles:/etc/ansible/roles \
	--volume ${DIR}/playbooks:/etc/ansible/playbooks \
	--volume ${DIR}/scripts:/etc/ansible/scripts \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	-e AWS_STACK_NAME=${AWS_STACK_NAME} \
	-e SSH_KEY_NAME=${AWS_SSH_KEY_NAME} \
	-v $(pwd)/aws/:/home/.aws/:ro \
	-v ${SSH_KEY_DIR}/${AWS_SSH_KEY_NAME}:/root/.ssh/${AWS_SSH_KEY_NAME}}:ro \
	f5-sca-ansible-dev \
	bash -c " /etc/ansible/scripts/revokeLicenses.sh 2>/dev/null"
	#bash -c "/etc/ansible/scripts/.ssh_key.sh && /etc/ansible/scripts/revokeLicenses.sh 2>/dev/null"
	
deletebuckets:
	@echo "delete buckets"
	@docker run -it \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	-e SSH_KEY_NAME=${AWS_SSH_KEY_NAME} \
	-e AWS_STACK_NAME=${AWS_STACK_NAME} \
	-v $(pwd)/aws/:/home/.aws/:ro \
	-v ${SSH_KEY_DIR}/${AWS_SSH_KEY_NAME}:/root/.ssh/${AWS_SSH_KEY_NAME}:ro \
	f5-sca-ansible-dev \
	bash -c "/etc/ansible/scripts/deleteBuckets.sh 2>/dev/null"

deletestack:
	@echo "delete stack"
	@echo "starting:" `date`
	@start_time="$(date -u +%s)"
	@docker run --rm -it \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	f5-sca-ansible-dev \
	bash -c "ansible-playbook playbooks/delete_sca_aws.yaml"
	@echo "complete" `date`
	@end_time="$(date -u +%s)"
	@elapsed="$((($end_time-$start_time)/60))"
	@echo "minutes elapsed: ${elapsed}"

deleteRg:
	@echo "delete stack"
	@echo "starting:" `date`
	@start_time="$(date -u +%s)"
	@docker run --rm -it \
	-e ARM_RESOURCE_GROUP=${ARM_RESOURCE_GROUP} \
	-e ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e ARM_TENANT_ID=${ARM_TENANT_ID} \
	-e ARM_CLIENT_ID=${ARM_CLIENT_ID} \
	-e ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} \
	-e AZURE_CLIENT_ID=${ARM_CLIENT_ID} \
	-e AZURE_SECRET=${ARM_CLIENT_SECRET} \
	-e AZURE_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e AZURE_TENANT=${ARM_TENANT_ID} \
	f5-sca-ansible-dev \
	bash -c "ansible-playbook playbooks/delete_sca_azure.yaml"
	@echo "complete" `date`
	@end_time="$(date -u +%s)"
	@elapsed="$((($end_time-$start_time)/60))"
	@echo "minutes elapsed: ${elapsed}"

shell:
	@echo " run docker container"
	@docker run -it \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	-e SSH_KEY_NAME=${AWS_SSH_KEY_NAME} \
	-e AWS_STACK_NAME=${AWS_STACK_NAME} \
	-e ARM_RESOURCE_GROUP=${ARM_RESOURCE_GROUP} \
	-e ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e ARM_TENANT_ID=${ARM_TENANT_ID} \
	-e ARM_CLIENT_ID=${ARM_CLIENT_ID} \
	-e ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} \
	-e AZURE_CLIENT_ID=${ARM_CLIENT_ID} \
	-e AZURE_SECRET=${ARM_CLIENT_SECRET} \
	-e AZURE_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e AZURE_TENANT=${ARM_TENANT_ID} \
	-v $(pwd)/aws/:/home/.aws/:ro \
	-v ${SSH_KEY_DIR}/${AWS_SSH_KEY_NAME}:/root/.ssh/${AWS_SSH_KEY_NAME}:ro \
	f5-sca-ansible-dev

test: testaws testazure

testaws: test1 test2 test3 test4

testazure: test1 test2 test6 test7 

test1:
	@echo "python test"
	@docker run --rm -it f5-sca-ansible-dev \
	bash -c "python --version"
test2:
	@echo "ansible test"
	@docker run --rm -it f5-sca-ansible-dev \
	bash -c "ansible --version"
test3:
	@echo "aws cli test"
	@docker run --rm -it f5-sca-ansible-dev \
	bash -c "aws --version"
test4:
	@echo "aws creds test"
	@docker run --rm \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	-it f5-sca-ansible-dev \
	bash -c "aws sts get-caller-identity"
test5:
	@echo "ansbile playbook test"
	@docker run --rm -e ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD} -it f5-sca-ansible-dev \
	bash -c "az login --service-principal --username ${ARM_CLIENT_ID} --password ${ARM_CLIENT_SECRET} --tenant ${ARM_TENANT_ID}; \
	ansible-playbook --vault-password-file ./.vault_pass.sh playbooks/test.yml"
test6:
	@echo "azure-cli test"
	@docker run --rm -it f5-sca-ansible-dev  \
	bash -c "az --version"
test7:
	@echo " test azure-cli login"
	@docker run --rm -e ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD} -it f5-sca-ansible-dev \
	bash -c "az login --service-principal --username ${ARM_CLIENT_ID} --password ${ARM_CLIENT_SECRET} --tenant ${ARM_TENANT_ID}"

test8:
	@echo "vault test"
	@docker run --rm -e ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD} -it f5-sca-ansible-dev \
	bash -c "az login --service-principal --username ${ARM_CLIENT_ID} --password ${ARM_CLIENT_SECRET} --tenant ${ARM_TENANT_ID}; \
	ansible-vault view --vault-password-file ./.vault_pass.sh group_vars/tag_name_mazza_wmt_demo_dev_f5vm/vault.yml"
test9:
	@echo " ansbile playbook test"
	@docker run --rm -e ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD} -it f5-sca-ansible-dev \
	bash -c "az login --service-principal --username ${ARM_CLIENT_ID} --password ${ARM_CLIENT_SECRET} --tenant ${ARM_TENANT_ID}; \
	ansible-playbook -i azure_rm.yml --vault-password-file ./.vault_pass.sh test.yml"
