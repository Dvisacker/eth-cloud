data "hcloud_image" "this" {
  with_selector = "name=${var.namespace}-snapshot"
  most_recent = true
}

data "hcloud_ssh_key" "this" {
  fingerprint = var.ssh_key_fingerprint
}

resource "hcloud_server" "this" {
  name        = "${var.namespace}-server"
  image       = data.hcloud_image.this.id
  server_type = "ccx33"
  location    = "ash"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  ssh_keys = [
    data.hcloud_ssh_key.this.id,
  ]
}

resource "hcloud_volume" "this" {
  name      = "${var.namespace}-volume"
  size      = 1000 # 1400 https://ycharts.com/indicators/ethereum_chain_full_sync_data_size
  server_id = hcloud_server.this.id
  automount = true
  format    = "ext4"
}