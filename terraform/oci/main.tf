locals {
  admin_user_id = "ocid1.user.oc1..aaaaaaaakfe6mukfk43qlbvnwsajk2qpatdxihiipbb67556ur3ei2c2nv7a"
}

resource "oci_kms_vault" "hcl_vault" {
  compartment_id = oci_identity_compartment.vault_autounseal.id
  display_name   = "hc-vault"
  vault_type     = "DEFAULT"
}

resource "oci_kms_key" "vault_autounseal" {
  compartment_id = oci_identity_compartment.vault_autounseal.id
  display_name   = "hc-key"
  key_shape {
    algorithm = "AES"
    length    = "32"
  }
  management_endpoint = oci_kms_vault.hcl_vault.management_endpoint
  protection_mode     = "HSM"
}

resource "oci_identity_compartment" "vault_autounseal" {
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
  name           = "vault-autounseal"
  description    = "Compartment for Vault auto-unseal resources"
}

resource "oci_identity_user" "vault_autounseal" {
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
  name           = "vault-autounseal-user"
  description    = "Service user for Vault auto-unseal operations"
  email = "vault-autounseal@yanello.net"
}

resource "oci_identity_group" "vault_autounseal" {
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
  name           = "vault-autounseal-group"
  description    = "Group with permissions for Vault auto-unseal"
}

resource "oci_identity_user_group_membership" "vault_autounseal" {
  group_id = oci_identity_group.vault_autounseal.id
  user_id  = oci_identity_user.vault_autounseal.id
}

resource "oci_identity_user_group_membership" "vault_autounseal_admin_user" {
  group_id = oci_identity_group.vault_autounseal.id
  user_id  = local.admin_user_id
}

resource "oci_identity_policy" "vault_autounseal" {
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
  name           = "vault-autounseal-policy"
  description    = "Policy for Vault auto-unseal KMS operations"
  
  statements = [
    "Allow group ${oci_identity_group.vault_autounseal.name} to manage keys in compartment ${oci_identity_compartment.vault_autounseal.name}",
    "Allow group ${oci_identity_group.vault_autounseal.name} to manage vaults in compartment ${oci_identity_compartment.vault_autounseal.name}",
    "Allow group ${oci_identity_group.vault_autounseal.name} to use key-delegate in compartment ${oci_identity_compartment.vault_autounseal.name}",
    "Allow group ${oci_identity_group.vault_autounseal.name} to manage objects in compartment ${oci_identity_compartment.vault_autounseal.name}"
  ]
}

data "sops_file" "vault-autounseal-private" {
  source_file     = "sops/vault-autounseal-private.enc.pem"
  input_type = "raw"
}
data "sops_file" "vault-autounseal-public" {
  source_file     = "sops/vault-autounseal-public.enc.pem"
  input_type = "raw"
}

resource "oci_identity_api_key" "vault_autounseal" {
  user_id   = oci_identity_user.vault_autounseal.id
  key_value = data.sops_file.vault-autounseal-public.raw
}
# 