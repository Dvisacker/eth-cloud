#!/bin/bash
set -eux

sudo apt-get update
sudo apt-get install -y ufw net-tools software-properties-common
sudo ufw disable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp # SSH access
sudo ufw allow 30303 # Geth P2P
sudo ufw allow 80 # HTTP
sudo ufw allow 443 # HTTPS
sudo ufw enable
sudo ufw status verbose
sudo netstat -tlnp

sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install -y geth

# Geth configuration
sudo tee /lib/systemd/system/geth.service > /dev/null <<EOF
[Unit]
Description=Geth Ethereum Node
After=network-online.target
Wants=network-online.target

[Service]
User=root
ExecStart=/usr/bin/geth --http --http.api eth,net,web3,txpool --metrics --metrics.addr 127.0.0.1 --metrics.port 6060
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable geth
sudo systemctl start geth

echo "Geth installation and configuration completed"



# /usr/bin/geth --metrics --metrics.influxdb --metrics.influxdb.endpoint http://0.0.0.0:8086 --metrics.influxdb.username geth --metrics.influxdb.password hunter2 --http --datadir /opt/geth/mainnet --cache 2048

# ExecStart=/usr/bin/geth --goerli --syncmode "fast" --cache 4096 --maxpeers 50