echo "Install geth"

yes | sudo add-apt-repository ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y ethereum

sudo su <<EOF2
cat > /lib/systemd/system/geth.service << EOF
[Unit]

Description=Geth Full Node
After=network-online.target
Wants=network-online.target

[Service]

WorkingDirectory=/root
User=root
ExecStart=/usr/bin/geth --http --http.addr "0.0.0.0" --http.port "8545" --http.corsdomain "*" --http.api personal,eth,net,web3,debug,txpool,admin --authrpc.jwtsecret /tmp/jwtsecret --ws --ws.port 8546 --ws.api eth,net,web3,txpool,debug --ws.origins="*" --metrics --maxpeers 150 
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
EOF2

sudo systemctl enable geth
sudo systemctl start geth