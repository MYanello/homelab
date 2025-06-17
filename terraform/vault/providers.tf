terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = " >= 5.0.0"
    }
  }
}

provider "vault" {
  address = "https://vault.yanello.net"
  # token is automatically read from VAULT_TOKEN environment variable
}