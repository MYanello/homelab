terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.0"
    }
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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30.0"
    }
  }
  backend "s3" {
    profile = "backblaze"
    bucket  = "myanello-tf"
    key     = "terraform/vault/terraform.tfstate"
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

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "homecontext"
}

data "sops_file" "oci" {
  source_file = "sops/oci.enc.yaml"
  input_type  = "yaml"
}

provider "oci" {
  tenancy_ocid     = data.sops_file.oci.data["tenancy_ocid"]
  user_ocid        = data.sops_file.oci.data["user_ocid"]
  fingerprint      = data.sops_file.oci.data["fingerprint"]
  private_key_path = data.sops_file.oci.data["private_key_path"]
  region           = data.sops_file.oci.data["region"]
}
