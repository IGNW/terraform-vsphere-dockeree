#!/bin/bash

if [ $# -lt 1 ];
    then echo "Usage: deploy.sh <cluster>"
    exit 1
fi

CLUSTER=$1

echo "Deploying Docker Enterprise Edition on cluster ${CLUSTER}"
terraform init -backend-config="settings/${CLUSTER}/${CLUSTER}.init"
terraform apply -auto-approve -var-file "settings/${CLUSTER}/${CLUSTER}.tfvars"
