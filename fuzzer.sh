#!/usr/bin/env bash

echo "Install slither"
sudo pip3 install slither-analyzer

echo "Install crytic-compile"
sudo pip3 install crytic-compile 

echo "Install solc-select"
sudo pip3 install solc-select

echo "Install echidna"
wget https://github.com/crytic/echidna/releases/download/v2.2.3/echidna-2.2.3-x86_64-linux.tar.gz -O echidna.tar.gz
tar -xvkf echidna.tar.gz
sudo mv echidna /usr/bin/
rm echidna.tar.gz

echo "Install go"
wget https://go.dev/dl/go1.21.1.linux-amd64.tar.gz -O go.tar.gz
sudo tar -C /usr/local -xzf go.tar.gz
rm go.tar.gz
export PATH="$PATH:/usr/local/go/bin"

echo "Install medusa"
wget https://github.com/crytic/medusa/releases/download/v0.1.3/medusa-linux-x64.tar.gz -O medusa.tar.gz
tar -xvkf medusa.tar.gz
rm medusa.tar.gz
sudo mv medusa /usr/bin/

echo "Install foundry"
curl -L https://foundry.paradigm.xyz | bash
export PATH="$PATH:$HOME/.foundry/bin"
foundryup
sudo mv .foundry/bin/* /usr/bin/

echo "Install halmos"
sudo pip3 install halmos
