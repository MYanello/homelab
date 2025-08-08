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

terraform {
  required_providers {
    # oci = {
    #   source  = "oracle/oci"
    #   version = ">= 4.0"
    # }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  # backend "s3" {
  #   bucket = "terraform"
  #   endpoints = {
  #     s3 = "https://minio.yanello.net"
  #   }
  #   key                         = "oci"
  #   region                      = "homelab"
  #   skip_credentials_validation = true # Skip AWS related checks and validations
  #   skip_requesting_account_id  = true
  #   skip_metadata_api_check     = true
  #   skip_region_validation      = true
  #   use_path_style              = true # Enable path-style S3 URLs, required for minio (https://<HOST>/<BUCKET> https://developer.hashicorp.com/terraform/language/settings/backends/s3#use_path_style
  # }
}
