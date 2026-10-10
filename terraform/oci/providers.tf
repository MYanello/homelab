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
