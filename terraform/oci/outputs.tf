output "vault_autounseal_user_ocid" {
  description = "OCID of the Vault auto-unseal service user"
  value       = oci_identity_user.vault_autounseal.id
  sensitive   = true
}

output "vault_autounseal_key_ocid" {
  description = "OCID of the KMS key for Vault auto-unseal"
  value       = oci_kms_key.vault_autounseal.id
  sensitive   = true
}

output "vault_autounseal_crypto_endpoint" {
  description = "Crypto endpoint for Vault auto-unseal"
  value       = oci_kms_vault.hcl_vault.crypto_endpoint
}

output "vault_autounseal_management_endpoint" {
  description = "Management endpoint for Vault auto-unseal"
  value       = oci_kms_vault.hcl_vault.management_endpoint
}

output "vault_autounseal_api_key_fingerprint" {
  description = "Fingerprint of the API key for Vault auto-unseal"
  value       = oci_identity_api_key.vault_autounseal.fingerprint
  sensitive   = true
}
