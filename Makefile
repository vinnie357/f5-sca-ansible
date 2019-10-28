.PHONY: build ansible


build:
	cd ./ansible/ && $(MAKE) build

ansibleShell:
	cd ./ansible/ && $(MAKE) shell

aws:
	cd ./ansible/ && $(MAKE) aws

azure:
	cd ./ansible/ && $(MAKE) aws

destroy:
	cd ./ansible/ && $(MAKE) destroy
