# final image
ARG AWS_REGION="us-east-1"

FROM alpine:latest
#ansible
RUN set -ex \
 && apk --update add rpm python3 openssl ca-certificates openssh-client bash jq \
 && apk --update add --virtual build-dependencies python3-dev libffi-dev openssl-dev build-base \
 && pip3 install --upgrade pip pycrypto cffi \
 && pip3 install ansible \
 && pip3 install jinja2==2.10.1 \
 && pip3 install netaddr==0.7.19 \
 && pip3 install pbr==5.2.0 \
 && pip3 install hvac==0.8.2 \
 && pip3 install jmespath==0.9.4 \
 && pip3 install ruamel.yaml==0.15.96 \
 && pip3 install f5-sdk \
 && pip3 install bigsuds \
 && pip3 install objectpath \
 && pip3 install packaging \
 && pip3 install boto3 botocore \
 && pip3 install awscli --upgrade \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* \
 && mkdir -p /etc/ansible
# python paths
RUN if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

# ansible config
COPY ansible.cfg /etc/ansible/ansible.cfg
COPY hosts /etc/ansible/hosts

# roles
RUN set -ex \
        && ansible-galaxy install f5devcentral.f5app_services_package \
        && ansible-galaxy install f5devcentral.bigip_onboard \
        && ansible-galaxy install f5devcentral.bigip_ha_cluster
#env vars
ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
# ENV PYTHONPATH /ansible/lib
# ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library

# aws config
ARG AWS_REGION
RUN mkdir -p /home/.aws/ && \
echo "[default]" > /home/.aws/config &&\
echo "output = text" >> /home/.aws/config &&\
echo "region = ${AWS_REGION}" >> /home/.aws/config


# default shell
# cat /etc/passwd | grep root
# sed -i 's/root\:x\:0\:0\:root\:\/root\:\/bin\/ash/root\:x\:0\:0\:root\:\/root\:\/bin\/bash/g' /etc/passwd
# cat /etc/passwd | grep root

# files/playbooks
COPY . .

WORKDIR /