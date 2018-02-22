#!/usr/bin/env bash
# This script initializes Consul, UCP, and DTR clusters.
# Further nodes are joined after the initial server/manager nodes are created.

API_BASE="http://127.0.0.1:8500/v1"
ADV_IP=$(/sbin/ip -f inet addr show dev eth0 | grep -Po 'inet \K[\d.]+')

function consul_server_init {
    echo "Initializing Consul server"
    docker run -d --net=host --name consul \
        consul agent -server \
        -bind="0.0.0.0" \
        -advertise="$ADV_IP" \
        -data-dir='/tmp' \
        -encrypt='${consul_secret}' \
        -retry-join="provider=aws tag_key=Role tag_value=${role}" \
        -bootstrap-expect=$(cat /tmp/node_count)

    wait_for_consul_leader
}

function get_leader {
    curl -s $API_BASE/status/leader | tr -d '"'
}

function wait_for_consul_leader {
    LEADER=$(get_leader)
    while [[ -z $LEADER || $LEADER == "No known Consul servers" || $LEADER == "No cluster leader" ]]; do
        echo "No Consul leader is available/elected yet. Sleeping for 15 seconds"
        sleep 15
        LEADER=$(get_leader)
    done
    echo "Consul leader is present: $LEADER"
}

function wait_for_ucp_manager {
    until $(curl -k --output /dev/null --silent --head --fail https://ucpmgr.service.consul); do
        echo "Waiting for existing UCP manager to be reachable via HTTPS"
        sleep 15
    done
    echo "Existing UCP manager is available"
}

function consul_agent_init {
    echo "Initializing Consul agent"
    docker run -d --net=host --name consul \
        consul agent \
        -bind="0.0.0.0" \
        -advertise="$ADV_IP" \
        -data-dir='/tmp' \
        -encrypt='${consul_secret}' \
        -retry-join="provider=aws tag_key=Role tag_value=dockeree-${environment}-mgr"

    wait_for_consul_leader
}

function create_ucp_swarm {
    echo "Creating UCP swarm"
    docker container run --rm -it --name ucp \
        -v /var/run/docker.sock:/var/run/docker.sock \
        docker/ucp:2.2.5 install \
        --host-address eth0 \
        --admin-username ${ucp_admin_username} \
        --admin-password ${ucp_admin_password} \
        --san ${ucp_dns_name}

    echo "Storing manager/worker join tokens for UCP"
    MANAGER_TOKEN=$(docker swarm join-token -q manager)
    WORKER_TOKEN=$(docker swarm join-token -q worker)
    curl -sX PUT -d "$MANAGER_TOKEN" $API_BASE/kv/ucp/manager_token
    curl -sX PUT -d "$WORKER_TOKEN" $API_BASE/kv/ucp/worker_token

    echo "Setting flag to indicate that the UCP swarm is initialized."
    curl -sX PUT -d "$HOSTNAME.node.consul" "$API_BASE/kv/ucp_swarm_initialized?release=$SID&flags=2"
    echo "Registering this node as a UCP manager"
    curl -sX PUT -d '{"Name": "ucpmgr", "Port": 2377}' $API_BASE/agent/service/register
}

function ucp_join_manager {
    wait_for_ucp_manager
    echo "UCP manager joining swarm"
    JOIN_TOKEN=$(curl -s $API_BASE/kv/ucp/manager_token | jq -r '.[0].Value' | base64 -d)
    docker swarm join --token $JOIN_TOKEN ucpmgr.service.consul:2377
    echo "Registering this node as a UCP manager"
    curl -sX PUT -d '{"Name": "ucpmgr", "Port": 2377}' $API_BASE/agent/service/register
}

function ucp_join_worker {
    wait_for_ucp_manager
    echo "UCP worker joining swarm"
    JOIN_TOKEN=$(curl -s $API_BASE/kv/ucp/worker_token | jq -r '.[0].Value' | base64 -d)
    docker swarm join --token $JOIN_TOKEN ucpmgr.service.consul:2377
}

function swarm_wait_until_ready {
    SWARM_TYPE=$1
    KEY=$2
    echo "Started polling for $SWARM_TYPE readiness"
    FLAGS=$(curl -s $API_BASE/kv/$KEY | jq -r '.[0].Flags')
    echo "$KEY FLAGS=$FLAGS"
    while [[ "$FLAGS" != "2" ]]; do
        echo "Waiting for $SWARM_TYPE swarm to be ready for join"
        sleep 15
        FLAGS=$(curl -s $API_BASE/kv/$KEY | jq -r '.[0].Flags')
        echo "$KEY FLAGS=$FLAGS"
    done
    echo "$SWARM_TYPE swarm is ready"
}

function dtr_install {
    wait_for_ucp_manager
    echo "Starting DTR install"
    REPLICA_ID=$(od -vN 6 -An -tx1 /dev/urandom | tr -d " \n")
    echo "a using random replica ID:$REPLICA_ID"

    # Add a hosts entry so that this works before the load balancer is up
    MGR_IP=$(dig +short ucpmgr.service.consul | head -1 | tr -d " \n")
    echo "$MGR_IP ${ucp_dns_name}" >> /etc/hosts

    docker run -it --rm docker/dtr install \
        --ucp-node $HOSTNAME \
        --ucp-username '${ucp_admin_username}' \
        --ucp-password '${ucp_admin_password}' \
        --ucp-insecure-tls \
        --replica-id $REPLICA_ID \
        --ucp-url https://${ucp_dns_name} \
        --dtr-external-url https://${dtr_dns_name}

    echo "Applying Minio config"
    /tmp/config_dtr_minio.sh

    curl -sX PUT -d "$REPLICA_ID" $API_BASE/kv/dtr/replica_id
    curl -sX PUT -d "$HOSTNAME.node.consul" "$API_BASE/kv/dtr_swarm_initialized?release=$SID&flags=2"
    echo "Finished initializing the DTR swarm"
}

function dtr_join {
    wait_for_ucp_manager
    echo "Starting DTR join"
    REPLICA_ID=$(curl -s $API_BASE/kv/dtr/replica_id | jq -r '.[0].Value' | base64 -d)
    echo "Retreived replace ID: $REPLICA_ID"

    # Ensure that only one DTR node can join at time to avoid contention.
    until [[ $(curl -sX PUT $API_BASE/kv/dtr/join_lock?acquire=$SID) == "true" ]]; do
        echo "Waiting to acquire DTR join lock"
        sleep 15
    done
    echo "Acquired DTR join lock"

    # Add a hosts entry so that this works before the load balancer is up
    MGR_IP=$(dig +short ucpmgr.service.consul | head -1 | tr -d " \n")
    echo "$MGR_IP ${ucp_dns_name}" >> /etc/hosts

    docker run -it --rm docker/dtr join \
        --ucp-node $HOSTNAME \
        --ucp-username '${ucp_admin_username}' \
        --ucp-password '${ucp_admin_password}' \
        --existing-replica-id $REPLICA_ID \
        --ucp-insecure-tls \
        --ucp-url https://${ucp_dns_name}

    echo "Releasing DTR join lock."
    curl -sX PUT $API_BASE/kv/dtr/join_lock?release=$SID
}

if [[ $HOSTNAME =~ mgr ]]; then
    consul_server_init
    SID=$(curl -sX PUT $API_BASE/session/create | jq -r '.ID')
    # Check a key to find out if the UCP swarm is already initialized
    FLAGS=$(curl -s $API_BASE/kv/ucp_swarm_initialized | jq -r '.[0].Flags')
    if [[ -z $FLAGS ]]; then
        echo "UCP swarm is uninitialized. Trying to get the lock."

        R=$(curl -sX PUT "$API_BASE/kv/ucp_swarm_initialized?acquire=$SID&flags=1")
        while [[ -z $R ]]; do
            echo "No response to attempt to get lock. Consul not ready yet? Sleeping..."
            sleep 10
            R=$(curl -sX PUT "$API_BASE/kv/ucp_swarm_initialized?acquire=$SID&flags=1")
        done

        if [[ $R == "true" ]]; then
            echo "Got the lock. Initializing the UCP swarm."
            create_ucp_swarm
        else
            echo "Someone else got the lock first? R:($R)"
            swarm_wait_until_ready ucp ucp_swarm_initialized
            ucp_join_manager
        fi

    elif [[ "$FLAGS" == "1" ]]; then
        echo "Found that swarm initialization is in progress"
        swarm_wait_until_ready ucp ucp_swarm_initialized
        ucp_join_manager

    elif [[ "$FLAGS" == "2" ]]; then
        echo "Found that the swarm is already initialized"
        ucp_join_manager
    fi
    curl -sX PUT $API_BASE/session/destroy/$SID

elif [[ $HOSTNAME =~ wrk ]]; then
    echo "This is a worker node"
    consul_agent_init
    swarm_wait_until_ready ucp ucp_swarm_initialized
    ucp_join_worker

elif [[ $HOSTNAME =~ dtr ]]; then
    echo "This is a DTR worker node"
    consul_agent_init
    swarm_wait_until_ready ucp ucp_swarm_initialized
    ucp_join_worker

    SID=$(curl -sX PUT $API_BASE/session/create | jq -r '.ID')
    FLAGS=$(curl -s $API_BASE/kv/dtr_swarm_initialized | jq -r '.[0].Flags')
    if [[ -z $FLAGS ]]; then
        echo "DTR swarm is uninitialized. Trying to get the lock."

        R=$(curl -sX PUT "$API_BASE/kv/dtr_swarm_initialized?acquire=$SID&flags=1")
        while [[ -z $R ]]; do
            echo "No response to attempt to get lock. Consul not ready yet? Sleeping..."
            sleep 10
            R=$(curl -sX PUT "$API_BASE/kv/dtr_swarm_initialized?acquire=$SID&flags=1")
        done

        if [[ $R == "true" ]]; then
            echo "Got the lock. Initializing the DTR swarm."
            dtr_install

        else
            echo "Someone else got the lock first? R:($R)"
            swarm_wait_until_ready dtr dtr_swarm_initialized
            dtr_join
        fi

    elif [[ "$FLAGS" == "1" ]]; then
        echo "Found that swarm initialization is in progress"
        swarm_wait_until_ready dtr dtr_swarm_initialized
        dtr_join

    elif [[ "$FLAGS" == "2" ]]; then
        echo "Found that the swarm is already initialized"
        dtr_join
    fi
    curl -sX PUT $API_BASE/session/destroy/$SID
fi

# TODO: uncomment this when I know everything works
#rm /tmp/swarm_init.sh
