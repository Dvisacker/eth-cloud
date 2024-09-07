resource "aws_security_group" "this" {
  name = "${var.namespace}-sg"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "ethereum-node"
  public_key = file("~/.ssh/id_rsa.pub")
}


resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = "m7i.xlarge"

  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true

  root_block_device {
    # https://paradigmxyz.github.io/reth/run/pruning.html
    # https://ycharts.com/indicators/ethereum_chain_full_sync_data_size
    # https://gist.github.com/yorickdowne/f3a3e79a573bf35767cd002cc977b038
    volume_size = 750
    volume_type = "gp3"
    iops = 10000
  }

  user_data = <<EOF
#!/bin/bash
set -eux
mkdir -p ~/.local/share/reth/mainnet/
wget -nv -O - https://downloads.merkle.io/reth-2024-04-05.tar.lz4 | tar -I lz4 -xvf - -C ~/.local/share/reth/mainnet/
sudo systemctl enable reth
sudo systemctl start reth
sudo systemctl enable lighthouse
sudo systemctl start lighthouse
EOF

  tags = {
    Name = "${var.namespace}-instance"
  }

  key_name = aws_key_pair.this.key_name
}
