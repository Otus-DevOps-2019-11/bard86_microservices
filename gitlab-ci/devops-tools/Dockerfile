FROM alpine:3.11

LABEL maintainer="Denis Barsukov <job.dbarsukov@gmail.com>"

RUN apk update \
    && apk --no-cache add curl \
    && apk --no-cache add ansible \
    && wget https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_amd64.zip -O /tmp/terraform.zip \
    && unzip -o -d /usr/local/bin /tmp/terraform.zip \
    && wget https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_linux_amd64.zip -O /tmp/packer.zip \
    && unzip -o -d /usr/local/bin /tmp/packer.zip \
    && wget https://github.com/terraform-linters/tflint/releases/download/v0.15.1/tflint_linux_amd64.zip -O /tmp/tflint.zip \
    && unzip -o -d /usr/local/bin /tmp/tflint.zip \
    && pip3 install --user ansible-lint requests google-auth\
    && wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-283.0.0-linux-x86_64.tar.gz -O /tmp/google-cloud-sdk.tar.gz \
    && tar -C "/" -zxvf /tmp/google-cloud-sdk.tar.gz google-cloud-sdk \
    && /google-cloud-sdk/install.sh \
    && rm -rf /var/cache/apk/* \
              /tmp/* \
              /var/tmp/*

ENV PATH="/google-cloud-sdk/bin:${PATH}"

CMD ["sh"]
