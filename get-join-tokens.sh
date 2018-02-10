#!/usr/bin/env bash

# Exit immediately if any of the following commands fail
set -e

# Extract "foo" and "baz" arguments from the input into
# FOO and BAZ shell variables.
# jq will ensure that the values are properly quoted
# and escaped for consumption by the shell.
eval "$(jq -r '@sh "HOST_ADDR=\(.mgr_addr) SSH_KEY_PATH=\(.ssh_key_path)"')"

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
SSH_CMD="ssh $SSH_OPTS -i $SSH_KEY_PATH"

# Get the manager join token
MANAGER_TOKEN=$($SSH_CMD centos@$HOST_ADDR sudo docker swarm join-token -q manager)

# Get the worker join token
WORKER_TOKEN=$($SSH_CMD centos@$HOST_ADDR sudo docker swarm join-token -q worker)

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg manager_token $MANAGER_TOKEN \
      --arg worker_token $WORKER_TOKEN \
      '{"manager_token":$manager_token, "worker_token":$worker_token}'
