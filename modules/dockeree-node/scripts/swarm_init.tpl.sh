#!/usr/bin/env bash
# This script initializes Consul, UCP, and DTR clusters.
# Further nodes are joined after the initial server/manager nodes are created.

set -e
API_BASE="http://127.0.0.1:8500/v1"
ADV_IP=$(/sbin/ip -f inet addr show dev eth0 | grep -Po 'inet \K[\d.]+')

source $(dirname "$0")/docker_util.sh

if [[ $HOSTNAME =~ mgr ]]; then
    info "This is a manager node"
    if [[ $HOSTNAME =~ 0 ]]; then
      info "This is the primary manager node"
      consul_cluster_init
      create_ucp_swarm
    else
      consul_server_init
      ucp_join_manager
    fi

elif [[ $HOSTNAME =~ wrk ]]; then
    info "This is a worker node"
    consul_agent_init
    ucp_join_worker

elif [[ $HOSTNAME =~ dtr ]]; then
    info "This is a DTR worker node"
    consul_agent_init
    ucp_join_worker

    SID=$(curl -sX PUT $API_BASE/session/create | jq -r '.ID')
    FLAGS=$(curl -s $API_BASE/kv/dtr_swarm_initialized | jq -r '.[0].Flags')
    if [[ -z $FLAGS ]]; then
        info "DTR swarm is uninitialized. Trying to get the lock."

        R=$(curl -sX PUT "$API_BASE/kv/dtr_swarm_initialized?acquire=$SID&flags=1")
        while [[ -z $R ]]; do
            info "No response to attempt to get lock. Consul not ready yet? Sleeping..."
            sleep 10
            R=$(curl -sX PUT "$API_BASE/kv/dtr_swarm_initialized?acquire=$SID&flags=1")
        done

        if [[ $R == "true" ]]; then
            info "Got the lock. Initializing the DTR swarm."
            dtr_install

        else
            info "Someone else got the lock first? R:($R)"
            swarm_wait_until_ready dtr dtr_swarm_initialized
            dtr_join
        fi

    elif [[ "$FLAGS" == "1" ]]; then
        info "Found that swarm initialization is in progress"
        swarm_wait_until_ready dtr dtr_swarm_initialized
        dtr_join

    elif [[ "$FLAGS" == "2" ]]; then
        info "Found that the swarm is already initialized"
        dtr_join
    fi
    curl -sX PUT $API_BASE/session/destroy/$SID
fi
info "CONFIGURATION COMPLETE"
