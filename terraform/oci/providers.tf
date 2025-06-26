data "sops_file" "this" {
  source_file     = "provider.enc.yaml"
  input_type = "yaml"
}

provider "oci" {
  tenancy_ocid     = data.sops_file.this.data["tenancy_ocid"]
  user_ocid        = data.sops_file.this.data["user_ocid"]
  fingerprint      = data.sops_file.this.data["fingerprint"]
  private_key_path = data.sops_file.this.data["private_key_path"]
  region           = data.sops_file.this.data["region"]
}

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}