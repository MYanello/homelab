resource "vault_mount" "pki" {
  path                      = "pki"
  type                      = "pki"
  description               = "Yanello root certificate authority"
  default_lease_ttl_seconds = 315360000
  max_lease_ttl_seconds     = 315360000
}

resource "vault_pki_secret_backend_root_cert" "root" {
  backend              = vault_mount.pki.path
  type                 = "internal"
  common_name          = "yanello-root-ca"
  ttl                  = "87600h"
  format               = "pem"
  private_key_format   = "der"
  key_type             = "ec"
  key_bits             = 256
  max_path_length      = 1
  exclude_cn_from_sans = true
}

resource "vault_mount" "pki_int" {
  path                      = "pki_int"
  type                      = "pki"
  description               = "Yanello intermediate certificate authority"
  default_lease_ttl_seconds = 43200
  max_lease_ttl_seconds     = 157680000
  allowed_response_headers  = ["Location", "Replay-Nonce", "Link"]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  backend     = vault_mount.pki_int.path
  type        = "internal"
  common_name = "yanello-intermediate-ca1"
  key_type    = "ec"
  key_bits    = 256
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  backend              = vault_mount.pki.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name          = "yanello-intermediate-ca1"
  ttl                  = "43800h"
  max_path_length      = 0
  use_csr_values       = true
  exclude_cn_from_sans = true
  depends_on           = [vault_pki_secret_backend_root_cert.root]
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

resource "vault_pki_secret_backend_config_urls" "pki_int" {
  backend = vault_mount.pki_int.path
  issuing_certificates = [
    "https://vault.yanello.net/v1/pki_int/ca"
  ]
  crl_distribution_points = [
    "https://vault.yanello.net/v1/pki_int/crl"
  ]
}

resource "vault_pki_secret_backend_config_cluster" "pki_int" {
  backend  = vault_mount.pki_int.path
  path     = "https://vault.yanello.net/v1/pki_int"
  aia_path = "https://vault.yanello.net/v1/pki_int"
}

resource "vault_pki_secret_backend_config_acme" "pki_int" {
  backend                  = vault_mount.pki_int.path
  enabled                  = true
  allowed_issuers          = ["*"]
  allowed_roles            = ["pikvm"]
  allow_role_ext_key_usage = false
  default_directory_policy = "forbid"
  dns_resolver             = ""
  eab_policy               = "not-required"

  depends_on = [vault_pki_secret_backend_config_cluster.pki_int]
}

resource "vault_pki_secret_backend_role" "cert_manager" {
  backend           = vault_mount.pki_int.path
  name              = "cert-manager"
  key_type          = "any"
  key_bits          = 0
  ttl               = "7776000"
  max_ttl           = "157680000"
  allow_any_name    = true
  allow_localhost   = false
  allow_ip_sans     = false
  server_flag       = true
  client_flag       = true
  code_signing_flag = true
  require_cn        = false
  enforce_hostnames = false
}

resource "vault_policy" "cert_manager" {
  name   = "cert-manager"
  policy = <<-POL
    path "${vault_mount.pki_int.path}/sign/cert-manager" {
      capabilities = ["create", "update"]
    }
    path "${vault_mount.pki_int.path}/cert/ca" {
      capabilities = ["read"]
    }
  POL
}

resource "vault_kubernetes_auth_backend_role" "cert_manager" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "cert-manager"
  bound_service_account_names      = ["vault-issuer"]
  bound_service_account_namespaces = ["cert-manager"]
  token_ttl                        = 3600
  token_max_ttl                    = 86400
  token_policies                   = [vault_policy.cert_manager.name]
}

resource "vault_pki_secret_backend_role" "pikvm" {
  backend            = vault_mount.pki_int.path
  name               = "pikvm"
  key_type           = "any"
  key_bits           = 0
  ttl                = "7776000"
  max_ttl            = "157680000"
  allowed_domains    = ["pikvm.yanello.net"]
  allow_bare_domains = true
  allow_ip_sans      = true
  server_flag        = true
  client_flag        = false
  code_signing_flag  = false
  require_cn         = false
  enforce_hostnames  = false
}
