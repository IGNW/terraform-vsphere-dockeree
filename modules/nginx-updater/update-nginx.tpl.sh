#!/usr/bin/bash

function timestamp {
  echo $(date "+%F %T")
}

function info {
  echo "$(timestamp) INFO:    $HOSTNAME $1"
}

info "Copying files"
cp ${script_path}/*.conf /etc/
info "Reloading NGINX containers"

mapfile -t CONTAINER_IDS < <( sudo docker ps -q )
for ID in "$${CONTAINER_IDS[@]}"; do
  info "Reloading container $ID"
  set -x
  docker container exec "$ID" nginx -s reload
  set +x
done
info "Done"
