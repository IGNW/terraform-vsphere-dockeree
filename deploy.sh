#!/bin/bash

function timestamp {
  echo $(date "+%F %T")
}

function info {
  echo "$(timestamp) INFO:  $1"
}

function error {
  echo "$(timestamp) ERROR: $1"
}

if [ $# -lt 1 ];
    then echo "Usage: deploy.sh <cluster>"
    exit 1
fi

CLUSTER=$1

if [ -z $PACKER_PATH ]; then
  PACKER_PATH="/usr/local/packer"
fi

if [ -z $PACKER_IMAGE ]; then
  PACKER_IMAGE="images/ubuntu-1804-vsphere.json"
fi

set -x
info "Deploying Docker Enterprise Edition on cluster ${CLUSTER}"

info "Building disk image template with Packer"
${PACKER_PATH} build ${PACKER_IMAGE}
result=$?
if [ $result -ne 0 ]; then
  error "Packer build failed"
  exit 1
fi

info "Initializing terraform"
terraform init -backend-config="clusters/${CLUSTER}/${CLUSTER}.init"
result=$?
if [ $result -ne 0 ]; then
  error "Terraform initalization faled"
  exit 1
fi

info "Applying terraform changes"
terraform apply -auto-approve -var-file "clusters/${CLUSTER}/${CLUSTER}.tfvars"
result=$?
if [ $result -ne 0 ]; then
  error "Terraform apply failed"
  exit 1
fi
