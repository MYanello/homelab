terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.0.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.4.0"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = ">= 2026.5.1"
    }
  }
  backend "s3" {
    profile = "backblaze"
    bucket  = "myanello-tf"
    key     = "terraform/oci/terraform.tfstate"
    endpoints = {
      s3 = "https://s3.us-west-004.backblazeb2.com"
    }
    region                      = "us-west-004"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
}

provider "vault" {
  address = "https://vault.yanello.net"
  # token is automatically read from VAULT_TOKEN environment variable
}

provider "authentik" {
  url = "https://authentik.yanello.net"
  # token is automatically read from AUTHENTIK_TOKEN environment variable
}