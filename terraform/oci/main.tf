provider "oci" {
  tenancy_ocid     = data.sops_file.this.data["tenancy_ocid"]
  user_ocid        = data.sops_file.this.data["user_ocid"]
  fingerprint      = data.sops_file.this.data["fingerprint"]
  private_key_path = data.sops_file.this.data["private_key_path"]
  region           = data.sops_file.this.data["region"]
}

locals {
  compartment_id   = var.compartment_id
  key_display_name = "hc-key"
}

data "sops_file" "this" {
  source_file     = "provider.enc.yaml"
  input_type = "yaml"
}

resource "oci_kms_vault" "hcl_vault" {
  compartment_id = local.compartment_id
  display_name   = "hc-vault"
  vault_type     = "DEFAULT"
}

resource "oci_kms_key" "this" {
  compartment_id = local.compartment_id
  display_name   = local.key_display_name
  key_shape {
    algorithm = "ECDSA"
    curve_id = "NIST_P521"
    length    = "66"
  }
  management_endpoint = oci_kms_vault.hcl_vault.management_endpoint
  protection_mode     = "HSM"
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