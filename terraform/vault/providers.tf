terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.0.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.2.0"
    }
  }
  # backend "s3" {
  #   bucket = "terraform"
  #   endpoints = {
  #     s3 = "https://minio.yanello.net"
  #   }
  #   key                         = "vault"
  #   region                      = "homelab"
  #   skip_credentials_validation = true # Skip AWS related checks and validations
  #   skip_requesting_account_id  = true
  #   skip_metadata_api_check     = true
  #   skip_region_validation      = true
  #   use_path_style              = true # Enable path-style S3 URLs, required for minio (https://<HOST>/<BUCKET> https://developer.hashicorp.com/terraform/language/settings/backends/s3#use_path_style
  # }
}

provider "vault" {
  address = "https://vault.yanello.net"
  # token is automatically read from VAULT_TOKEN environment variable
}