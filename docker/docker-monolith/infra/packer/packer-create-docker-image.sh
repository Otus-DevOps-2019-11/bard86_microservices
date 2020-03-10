#!/bin/bash
set -e
packer validate -var-file=variables.json docker.json
packer build -var-file=variables.json docker.json
