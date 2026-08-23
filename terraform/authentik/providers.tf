terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = ">= 2026.5.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.4.1"
    }
  }

  backend "s3" {
    profile = "backblaze"
    bucket  = "myanello-tf"
    key     = "terraform/authentik.tfstate"
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

data "sops_file" "authentik" {
  source_file = "sops.yaml"
  input_type  = "yaml"
}

provider "authentik" {
  url   = "https://authentik.yanello.net"
  token = data.sops_file.authentik.data["token"]
}
