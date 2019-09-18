.PHONY: build test deploy aws azure


build:
	docker build --build-arg AWS_REGION=${AWS_REGION} -t f5-sca-ansible-dev .

deployAWS:
	@docker run --rm -it \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}\
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}\
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	f5-sca-ansible-dev \
	bash -c "ansible-playbook deploy_sca_aws.yaml"

aws: build test deployAWS

azure: build test deployAzure

setup:
	@echo "make vault keys"
	@echo "configure aws creds"
	.env_vars_helper.sh

creds:
	@docker run --rm -it \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_STACK_NAME=${AWS_STACK_NAME} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	f5-sca-ansible-dev \
	bash -c "./scripts/getpass.sh;\
	./scripts/getMgmt.sh"

connect:
	#run docker get list
	#print list
	#connect to list
destroy: revokelicense deletestack

revokelicense:
	@echo "revoke license"
	@docker run --rm -it \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	-v $(pwd)/aws/:/home/.aws/:ro \
	-v ~/.ssh:/root/.ssh \
	f5-sca-ansible-dev \
	bash -c ". scripts/revokeLicenses.sh"
deletestack:
	@echo "delete stack"
	@docker run --rm -it \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}\
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}\
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	f5-sca-ansible-dev \
	bash -c "ansible-playbook delete_sca_aws.yaml"
shell:
	@echo " run docker container"
	@docker run --rm -it \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	-v $(pwd)/aws/:/home/.aws/:ro \
	f5-sca-ansible-dev

test: test1 test2 test3 test4

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
	ansible-playbook --vault-password-file ./.vault_pass.sh test.yml"

