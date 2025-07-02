locals {
  vault_addr = "https://vault.yanello.net"
}

resource "vault_audit" "stdout" {
  type = "file"
  options = {
    file_path = "stdout"
  }
}

 resource "vault_mount" "kv" {
  path        = "secret"
  type        = "kv"
  description = "Key-Value Secrets Engine"
  options = {
    version = "2"
    type    = "kv-v2"
  }
}