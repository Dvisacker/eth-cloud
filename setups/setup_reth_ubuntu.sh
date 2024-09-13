set -eux

sudo apt-get update
sudo apt-get install -y ufw
sudo apt-get install -y net-tools
sudo apt-get install -y lz4 # install lz4 for decompression
sudo apt-get install -y python3-pip
sudo ufw disable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp # SSH access
sudo ufw allow 30303 # P2P
sudo ufw allow 9000 # Lighthouse P2P
sudo ufw allow 80 # HTTP
sudo ufw allow 443 # HTTPS
sudo ufw allow 9001 # Metrics
sudo ufw enable

sudo ufw status verbose
sudo netstat -tlnp

echo "Install reth"

wget https://github.com/paradigmxyz/reth/releases/download/v0.2.0-beta.5/reth-v0.2.0-beta.5-x86_64-unknown-linux-gnu.tar.gz
tar zxvf reth-v0.2.0-beta.5-x86_64-unknown-linux-gnu.tar.gz
rm reth-v0.2.0-beta.5-x86_64-unknown-linux-gnu.tar.gz
sudo mv reth /usr/local/bin/

sudo su <<EOF2
cat > /lib/systemd/system/reth.service << EOF
[Unit]

Description=Reth Full Node
After=network-online.target
Wants=network-online.target

[Service]

WorkingDirectory=/root
User=root
ExecStart=/usr/local/bin/reth node --full --http --http.api "admin,debug,eth,net,trace,txpool,web3,rpc" --metrics 127.0.0.1:9001
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
EOF2

sudo systemctl enable reth
sudo systemctl start reth

echo "Install lighthouse"

wget https://github.com/sigp/lighthouse/releases/download/v5.1.3/lighthouse-v5.1.3-x86_64-unknown-linux-gnu.tar.gz
tar zxvf lighthouse-v5.1.3-x86_64-unknown-linux-gnu.tar.gz
rm lighthouse-v5.1.3-x86_64-unknown-linux-gnu.tar.gz
sudo mv lighthouse /usr/local/bin/

sudo su <<EOF2
cat > /lib/systemd/system/lighthouse.service << EOF
[Unit]

Description=Lighthouse consensus client
After=network-online.target
Wants=network-online.target

[Service]

WorkingDirectory=/root
User=root
ExecStart=/usr/local/bin/lighthouse bn --network mainnet --execution-endpoint http://localhost:8551 --execution-jwt /root/.local/share/reth/mainnet/jwt.hex --checkpoint-sync-url https://mainnet.checkpoint.sigp.io --disable-deposit-contract-sync
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
EOF2

sudo systemctl enable lighthouse
sudo systemctl start lighthouse
