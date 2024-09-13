variable "hcloud_token" {
  description = "Hetzner API token"
  sensitive   = true
}

variable "hcloud_ssh_key" {
  description = "SSH Key"
}

variable "namespace" {
  description = "Namespace"
}