variable "namespace" {
  type = string
  default = "hetzner-reth-op"
}

variable "hcloud_token" {
  type = string
}

packer {
  required_plugins {
    hcloud = {
      version = ">= 1.2.0"
      source  = "github.com/hetznercloud/hcloud"
    }
  }
}

source "hcloud" "base-amd64" {
  token         = "${var.hcloud_token}"
  image         = "ubuntu-22.04"
  location      = "hel1"
  server_type   = "cx11"
  ssh_keys      = []
  user_data     = ""
  ssh_username  = "root"
  snapshot_name = "${var.namespace}-snapshot"
  snapshot_labels = {
    "name" = "${var.namespace}-snapshot"
  }
}

build {
  sources = ["source.hcloud.base-amd64"]
  provisioner "shell" {
    script = "../setups/setup_op_reth_ubuntu_docker.sh"
  }
}