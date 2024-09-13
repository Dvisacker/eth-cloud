variable "namespace" {
  type = string
}

packer {
  required_plugins {
    hcloud = {
      source  = "github.com/hetznercloud/hcloud"
      version = ">= 1.2.0"
    }
  }
}

source "hcloud" "base-amd64" {
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
    script = "../setup.sh"
  }
}
