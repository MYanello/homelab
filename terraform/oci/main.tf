locals {
  compartment_id   = var.compartment_id
  key_display_name = "hc-key"
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
