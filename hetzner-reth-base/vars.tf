variable "hcloud_token" {
  description = "Hetzner API token"
  sensitive   = true
}

variable "ssh_key_fingerprint" {
  description = "SSH key fingerprint"
}

variable "namespace" {
  description = "Namespace"
  default = "hetzner-reth-base"
}

