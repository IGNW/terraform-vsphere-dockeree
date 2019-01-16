API_BASE="http://127.0.0.1:8500/v1"
curl -sX DELETE "$API_BASE/kv/dtr_swarm_initialized"
sudo docker stop consul
sudo docker rm consul
sudo docker swarm leave
