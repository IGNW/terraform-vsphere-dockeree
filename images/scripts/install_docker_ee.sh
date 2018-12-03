sudo apt-get update -y
sudo apt-get install -y chrony dnsmasq dnsutils jq
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo systemctl enable dnsmasq
echo 'server=/consul/127.0.0.1#8600' | sudo tee /etc/dnsmasq.d/10-consul
echo 'prepend domain-name-servers 127.0.0.1;' | sudo tee --append /etc/dhcp/dhclient.conf
echo 'prepend domain-search \"consul\", \"node.consul\";' | sudo tee --append /etc/dhcp/dhclient.conf
echo 'server 169.254.169.123 prefer iburst' | sudo tee --append /etc/chrony.conf
DOCKER_EE_URL="https://storebits.docker.com/ee/ubuntu/sub-d8013021-7ac0-42ed-bec6-b0e9e114295f"
curl -fsSL "${DOCKER_EE_URL}/ubuntu/gpg" | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] $DOCKER_EE_URL/ubuntu $(lsb_release -cs) stable-18.09"
sudo apt-get update -y
sudo apt-get install -y docker-ee
sudo docker run hello-world
