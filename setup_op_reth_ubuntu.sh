#!/bin/bash
set -eux

# Update and upgrade the system
sudo apt-get update
sudo apt-get install -y ufw
sudo apt-get install -y net-tools
sudo apt-get install -y lz4 # install lz4 for decompression
sudo apt-get install -y python3-pip
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y ufw net-tools lz4 python3-pip

# Install Docker
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d '"' -f 4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Configure firewall
sudo ufw disable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp # SSH access
sudo ufw allow 30303 # P2P
sudo ufw allow 8545 # HTTP RPC
sudo ufw allow 8546 # WebSocket RPC
sudo ufw allow 80 # HTTP
sudo ufw allow 443 # HTTPS
sudo ufw allow 9001 # Metrics
sudo ufw allow 9004 # op-node P2P
sudo ufw enable

sudo ufw status verbose
sudo netstat -tlnp

echo "Install op-reth"

# Install op-reth
RETH_VERSION="v1.0.6"
wget "https://github.com/paradigmxyz/reth/releases/download/${RETH_VERSION}/op-reth-${RETH_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
tar zxvf "op-reth-${RETH_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
rm "op-reth-${RETH_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
sudo mv op-reth /usr/local/bin/

# Generate JWT secret
sudo mkdir -p /root/.ethereum
openssl rand -hex 32 | tr -d "\n" | sudo tee /root/.ethereum/jwt.hex
sudo chmod 644 /root/.ethereum/jwt.hex

# Create op-reth service
sudo tee /lib/systemd/system/op-reth.service > /dev/null << EOF
[Unit]
Description=Op-Reth Execution Client
After=network-online.target
Wants=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/op-reth node \
    --chain base \
    --rollup.sequencer-http https://mainnet-sequencer.base.org \
    --http \
    --ws \
    --authrpc.jwtsecret /root/.ethereum/jwt.hex \
    --authrpc.port 9551 \
    --metrics 127.0.0.1:9001 \
    -vvvv
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

echo "Install op-node with Docker"

# Create op-node Docker service
sudo tee /lib/systemd/system/op-node-docker.service > /dev/null << EOF
[Unit]
Description=Op-Node Rollup Client (Docker)
After=docker.service op-reth.service
Requires=docker.service
Wants=op-reth.service

[Service]
ExecStartPre=-/usr/bin/docker stop op-node
ExecStartPre=-/usr/bin/docker rm op-node
ExecStart=/usr/bin/docker run --rm --name op-node \
    -v /root/.ethereum:/root/.ethereum:ro \
    -p 9004:9004/tcp \
    -p 9004:9004/udp \
    --network host \
    us-docker.pkg.dev/oplabs-tools-artifacts/images/op-node:latest \
    op-node \
    --network=base-mainnet \
    --syncmode=execution-layer \
    --l1=wss://eth.merkle.io \
    --l1.trustrpc \
    --l1.beacon=https://ethereum-beacon-api.publicnode.com \
    --l2=http://0.0.0.0:9551 \
    --l2.jwt-secret=/root/.ethereum/jwt.hex \
    --l2.enginekind=reth \
    --p2p.listen.tcp=9004 \
    --p2p.listen.udp=9004
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable op-reth op-node-docker
sudo systemctl start op-reth op-node-docker

echo "Optimism node setup complete. Check the logs with 'journalctl -u op-reth -f' and 'journalctl -u op-node-docker -f'"


/usr/bin/docker run --rm --name op-node \
    -v /root/.ethereum:/root/.ethereum:ro \
    -p 9004:9004/tcp \
    -p 9004:9004/udp \
    us-docker.pkg.dev/oplabs-tools-artifacts/images/op-node:latest \
    op-node \
    --network=base-mainnet \
    --syncmode=execution-layer \
    --l1=wss://eth.merkle.io \
    --l1.trustrpc \
    --l1.beacon=https://ethereum-beacon-api.publicnode.com \
    --l2=http://0.0.0.0:9551 \
    --l2.jwt-secret=/root/.ethereum/jwt.hex \
    --l2.enginekind=reth \
    --p2p.listen.tcp=9004 \
    --p2p.listen.udp=9004