#!/usr/bin/env bash
# This script initializes Consul, UCP, and DTR clusters.
# Further nodes are joined after the initial server/manager nodes are created.

set -e
API_BASE="http://127.0.0.1:8500/v1"
ADV_IP=$(/sbin/ip -f inet addr show dev ens160 | grep -Po 'inet \K[\d.]+')
UCP_VERSION=2.2.5

function timestamp {
  echo $(date "+%F %T")
}

function debug {
  echo "$(timestamp) DEBUG:  $HOSTNAME $1"
}

function info {
  echo "$(timestamp) INFO:  $HOSTNAME $1"
}

function error {
  echo "$(timestamp) ERROR: $HOSTNAME $1"
}

function consul_cluster_init {
  info "Initializing Consul cluster"
  docker run -d --net=host --name consul \
      consul agent -server \
      -bind="0.0.0.0" \
      -advertise="$ADV_IP" \
      -data-dir='/tmp' \
      -encrypt='${consul_secret}' \
      -bootstrap-expect="1"
}

function consul_server_init {
    info "Initializing Consul server"
    docker run -d --net=host --name consul \
        consul agent -server \
        -bind="0.0.0.0" \
        -advertise="$ADV_IP" \
        -data-dir='/tmp' \
        -encrypt='${consul_secret}' \
        -retry-join="${manager_zero_ip}"

    wait_for_consul_leader
}

function get_leader {
    curl -s $API_BASE/status/leader | tr -d '"'
}

function wait_for_consul_leader {
    LEADER=$(get_leader)
    while [[ -z $LEADER || $LEADER == "No known Consul servers" || $LEADER == "No cluster leader" ]]; do
        info "No Consul leader is available/elected yet. Sleeping for 15 seconds"
        sleep 15
        LEADER=$(get_leader)
    done
    info "Consul leader is present: $LEADER"
}

function wait_for_ucp_manager {
    until $(curl -k --output /dev/null --silent --head --fail https://ucpmgr.service.consul); do
        info "Waiting for existing UCP manager to be reachable via HTTPS"
        sleep 15
    done
    info "Existing UCP manager is available"
}

function consul_agent_init {
    info "Initializing Consul agent"
    docker run -d --net=host --name consul \
        consul agent \
        -bind="0.0.0.0" \
        -advertise="$ADV_IP" \
        -data-dir='/tmp' \
        -encrypt='${consul_secret}' \
        -retry-join="${manager_zero_ip}"

    wait_for_consul_leader
}

function create_ucp_swarm {
    info "Creating UCP swarm"
    docker container run --rm -it --name ucp \
        -v /var/run/docker.sock:/var/run/docker.sock \
        docker/ucp:2.2.5 install \
        --host-address ens160 \
        --admin-username ${ucp_admin_username} \
        --admin-password ${ucp_admin_password} \

    info "Storing manager/worker join tokens for UCP"
    MANAGER_TOKEN=$(docker swarm join-token -q manager)
    WORKER_TOKEN=$(docker swarm join-token -q worker)
    curl -sX PUT -d "$MANAGER_TOKEN" $API_BASE/kv/ucp/manager_token
    curl -sX PUT -d "$WORKER_TOKEN" $API_BASE/kv/ucp/worker_token

    info "Registering this node as a UCP manager"
    curl -sX PUT -d '{"Name": "ucpmgr", "Port": 2377}' $API_BASE/agent/service/register
}

function ucp_join_manager {
    wait_for_ucp_manager
    info "UCP manager joining swarm"
    JOIN_TOKEN=$(curl -s $API_BASE/kv/ucp/manager_token | jq -r '.[0].Value' | base64 -d)
    docker swarm join --token $JOIN_TOKEN ucpmgr.service.consul:2377
    info "Registering this node as a UCP manager"
    curl -sX PUT -d '{"Name": "ucpmgr", "Port": 2377}' $API_BASE/agent/service/register
}

function ucp_join_worker {
    wait_for_ucp_manager
    info "UCP worker joining swarm"
    JOIN_TOKEN=$(curl -s $API_BASE/kv/ucp/worker_token | jq -r '.[0].Value' | base64 -d)
    docker swarm join --token $JOIN_TOKEN ucpmgr.service.consul:2377
}

function swarm_wait_until_ready {
    SWARM_TYPE=$1
    KEY=$2
    info "Started polling for $SWARM_TYPE readiness"
    FLAGS=$(curl -s $API_BASE/kv/$KEY | jq -r '.[0].Flags')
    info "$KEY FLAGS=$FLAGS"
    while [[ "$FLAGS" != "2" ]]; do
        info "Waiting for $SWARM_TYPE swarm to be ready for join"
        sleep 15
        FLAGS=$(curl -s $API_BASE/kv/$KEY | jq -r '.[0].Flags')
        info "$KEY FLAGS=$FLAGS"
    done
    info "$SWARM_TYPE swarm is ready"
}

function dtr_install {
    wait_for_ucp_manager
    info "Starting DTR install"
    REPLICA_ID=$(od -vN 6 -An -tx1 /dev/urandom | tr -d " \n")
    info "Using random replica ID:$REPLICA_ID"

    # Add a hosts entry so that this works before the load balancer is up
    MGR_IP=$(dig +short ucpmgr.service.consul | head -1 | tr -d " \n")
    echo "$MGR_IP ${manager_zero_ip}" >> /etc/hosts

    docker run -it --rm docker/dtr install \
        --ucp-node $HOSTNAME \
        --ucp-username '${ucp_admin_username}' \
        --ucp-password '${ucp_admin_password}' \
        --ucp-insecure-tls \
        --replica-id $REPLICA_ID \
        --ucp-url https://${manager_zero_ip} \
        --dtr-external-url https://$ADV_IP


    debug "Installing pip"
    debug "$(apt-get intstall python-pip)"
    debug "Installing \'requests\'"
    debug "$(pip install requests)"
    info "Applying Minio config"
    echo "$(/tmp/config_dtr_minio.sh)"
    debug "Done applying minio config"

    debug "Putting replica ID into KV"
    curl -sX PUT -d "$REPLICA_ID" $API_BASE/kv/dtr/replica_id
    debug "Marking swarm initialization as complute in KV"
    curl -sX PUT -d "$HOSTNAME.node.consul" "$API_BASE/kv/dtr_swarm_initialized?release=$SID&flags=2"
    info "Finished initializing the DTR swarm"
}

function dtr_join {
    wait_for_ucp_manager
    info "Starting DTR join"
    REPLICA_ID=$(curl -s $API_BASE/kv/dtr/replica_id | jq -r '.[0].Value' | base64 -d)
    info "Retreived replace ID: $REPLICA_ID"

    # Ensure that only one DTR node can join at time to avoid contention.
    until [[ $(curl -sX PUT $API_BASE/kv/dtr/join_lock?acquire=$SID) == "true" ]]; do
        info "Waiting to acquire DTR join lock"
        sleep 15
    done
    info "Acquired DTR join lock"

    # Add a hosts entry so that this works before the load balancer is up
    MGR_IP=$(dig +short ucpmgr.service.consul | head -1 | tr -d " \n")
    echo "$MGR_IP ${ucp_dns_name}" >> /etc/hosts

    docker run -it --rm docker/dtr join \
        --ucp-node $HOSTNAME \
        --ucp-username '${ucp_admin_username}' \
        --ucp-password '${ucp_admin_password}' \
        --existing-replica-id $REPLICA_ID \
        --ucp-insecure-tls \
        --ucp-url https://${manager_zero_ip}

    info "Releasing DTR join lock."
    curl -sX PUT $API_BASE/kv/dtr/join_lock?release=$SID
}

function docker_pull_and_tag {
  info "Pulling $1"
  docker pull ${docker_registry}/$1
  docker tag ${docker_registry}/$1 $1
}

function docker_pull_ucp_components {
  docker_pull_and_tag docker/ucp-swarm:$UCP_VERSION
  docker_pull_and_tag docker/ucp-etcd:$UCP_VERSION
  docker_pull_and_tag docker/ucp-hrm:$UCP_VERSION
  docker_pull_and_tag docker/ucp-controller:$UCP_VERSION
  docker_pull_and_tag docker/ucp-agent:$UCP_VERSION
  docker_pull_and_tag docker/ucp-auth:$UCP_VERSION
  docker_pull_and_tag docker/ucp-auth-store:$UCP_VERSION
  docker_pull_and_tag docker/ucp-metrics:$UCP_VERSION
  docker_pull_and_tag docker/ucp-cfssl:$UCP_VERSION
  docker_pull_and_tag docker/ucp-dsinfo:$UCP_VERSION
  docker_pull_and_tag docker/ucp-compose:$UCP_VERSION
}

# SCRIPT BEGINS

if [ -n "${docker_registry}" ]; then
  info "Using docker registry ${docker_registry}"
  echo "{ \"insecure-registries\":[\"${docker_registry}\"] }" | sudo tee /etc/docker/daemon.json
  sudo systemctl restart docker
  docker_pull_and_tag consul:latest
fi
if [[ $HOSTNAME =~ mgr ]]; then
    info "This is a manager node"
    if [ -n "${docker_registry}" ]; then
      docker_pull_and_tag docker/ucp:$UCP_VERSION
      docker_pull_ucp_components
    fi
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
    if [ -n "${docker_registry}" ]; then
      docker_pull_and_tag docker/dtr:latest
    fi
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
