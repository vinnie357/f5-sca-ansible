FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y python python-dev python-pip python-jmespath && \
    apt-get install -y openssh-client iputils-ping sshpass 

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install ansible boto boto3 botocore

COPY ansible.cfg /etc/ansible/ansible.cfg


COPY . .
