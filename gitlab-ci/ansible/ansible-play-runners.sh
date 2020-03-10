#!/usr/bin/env bash

set -e

GCP_SERVICE_ACCOUNT_FILE=~/docker-267311-serviceaccount.json
export GCP_SERVICE_ACCOUNT_FILE
ansible-playbook ./playbooks/docker_runner/playbook.yml --key-file ~/.ssh/appuser
