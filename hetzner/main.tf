data "hcloud_image" "this" {
  with_selector = "name=${var.namespace}-snapshot"
  most_recent = true
}

resource "hcloud_server" "this" {
  name        = "${var.namespace}-server"
  image       = data.hcloud_image.this.id
  server_type = "cx41"
  location    = "hel1"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  ssh_keys = [
    var.hcloud_ssh_key,
  ]
}

resource "hcloud_volume" "this" {
  name      = "${var.namespace}-volume"
  size      = 100 # 1400 https://ycharts.com/indicators/ethereum_chain_full_sync_data_size
  server_id = hcloud_server.this.id
  automount = true
  format    = "ext4"
}