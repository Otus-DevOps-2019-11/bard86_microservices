#!/bin/bash
set -e
packer validate -var-file=packer/variables.json packer/docker.json
packer build -var-file=packer/variables.json packer/docker.json
