resource "vault_mount" "pki" {
  path                      = "pki"
  type                      = "pki"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 5256000
}

resource "vault_pki_secret_backend_root_cert" "root" {
  depends_on  = [vault_mount.pki]
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "Root CA"
  ttl         = "5256000"
  issuer_name = "root-2025"
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki.path
  name             = "2025-servers"
  allow_any_name = true
}

resource "vault_pki_secret_backend_config_urls" "pki_urls" {
  backend = vault_mount.pki.path

  issuing_certificates    = ["${local.vault_addr}/v1/pki/ca"]
  crl_distribution_points = ["${local.vault_addr}/v1/pki/crl"]
}


resource "vault_mount" "pki_int" {
  path                      = "pki_int"
  type                      = "pki"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 2628000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate_csr" {
  backend     = vault_mount.pki_int.path
  type        = "internal"
  common_name = "Intermediate Authority"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "sign_intermediate" {
  backend     = vault_mount.pki.path         # Root PKI mount path, e.g., "pki"
  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate_csr.csr
  common_name = "Intermediate Authority"
  issuer_ref  = vault_pki_secret_backend_root_cert.root.issuer_name
  format      = "pem_bundle"
  ttl         = "43800h"
}