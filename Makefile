.PHONY: build ansible aws azure testaws testazure destroyAzure shell


build:
	cd ansible/ && $(MAKE) build

shell:
	cd ansible/ && $(MAKE) shell

aws:
	cd ./ansible/ && $(MAKE) aws

azure:
	cd ./ansible/ && $(MAKE) azure

test:
	cd ansible/ && $(MAKE) test

testaws:
	cd ansible/ && $(MAKE) testaws

testazure:
	cd ansible/ && $(MAKE) testazure

destroyAWS:
	cd ./ansible/ && $(MAKE) destroyAWS

destroyAzure:
	cd ansible/ && $(MAKE) deleteRg

