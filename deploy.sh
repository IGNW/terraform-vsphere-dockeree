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
  PACKER_IMAGE="ubuntu-1604-vsphere.json"
fi

if [ -z $TFSTATE_PATH ]; then
  TFSTATE_PATH="/usr/local/terraform/${CLUSTER}.tfstate"
fi

if [ -z $BUILD_DISK_IMAGE ]; then
  BUILD_DISK_IMAGE=true
fi

set -x
info "Deploying Docker Enterprise Edition on cluster ${CLUSTER}"

if [ $BUILD_DISK_IMAGE == "true" ]; then
  info "Building disk image template with Packer"
  cd images
  ${PACKER_PATH} build -force ${PACKER_IMAGE}
  result=$?
  if [ $result -ne 0 ]; then
    error "Packer build failed"
    exit 1
  fi
  cd ..
else
  echo "Skipping Packer Build step because BUILD_DISK_IMAGE = ${BUILD_DISK_IMAGE}"
fi

info "Initializing terraform"
terraform init -backend-config="clusters/${CLUSTER}/${CLUSTER}.init"
result=$?
if [ $result -ne 0 ]; then
  error "Terraform initalization failed"
  exit 1
fi

info "Applying terraform changes"
terraform apply -auto-approve -var-file "clusters/${CLUSTER}/${CLUSTER}.tfvars"
result=$?
if [ $result -ne 0 ]; then
  error "Terraform apply failed"
  exit 1
fi
