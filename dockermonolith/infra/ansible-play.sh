#!/bin/bash
set -e

#ansible-playbook ./ansible/playbooks/docker_ubuntu1604/playbook.yml
ansible-playbook ./ansible/playbooks/reddit_container/playbook.yml
