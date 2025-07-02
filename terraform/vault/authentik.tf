data "sops_file" "authentik" {
  source_file = "sops/authentik.yaml"
  input_type  = "yaml"
}

resource "vault_jwt_auth_backend" "authentik" {
  description        = "Vault Authentik Terraform JWT auth backend"
  path               = "oidc"
  type               = "oidc"
  default_role       = "admin"
  oidc_discovery_url = "https://authentik.yanello.net/application/o/vault/"
  oidc_client_id     = data.sops_file.authentik.data["client_id"]
  oidc_client_secret = data.sops_file.authentik.data["client_secret"]
}

resource "vault_jwt_auth_backend_role" "reader" {
  backend        = vault_jwt_auth_backend.authentik.path
  role_name      = "reader"
  token_policies = ["reader"]
  user_claim     = "sub"
  groups_claim   = "groups"
  oidc_scopes    = ["openid", "profile", "email"]
  role_type      = "oidc"
  allowed_redirect_uris = [
    "https://vault.yanello.net/ui/vault/auth/oidc/oidc/callback",
    "https://vault.yanello.net/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]
}
resource "vault_identity_group" "reader" {
  name     = "reader"
  type     = "external"
  policies = ["reader"]
}
resource "vault_identity_group_alias" "reader-group-alias" {
  name           = "reader"
  mount_accessor = vault_jwt_auth_backend.authentik.accessor
  canonical_id   = vault_identity_group.reader.id
}

resource "vault_jwt_auth_backend_role" "admin" {
  backend        = vault_jwt_auth_backend.authentik.path
  role_name      = "admin"
  token_policies = ["admin"]
  user_claim     = "sub"
  groups_claim   = "groups"
  oidc_scopes    = ["openid", "profile", "email"]
  role_type      = "oidc"
  allowed_redirect_uris = [
    "https://vault.yanello.net/ui/vault/auth/oidc/oidc/callback",
    "https://vault.yanello.net/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]
}

resource "vault_identity_group" "admin" {
  name     = "admin"
  type     = "external"
  policies = ["admin"]
}
resource "vault_identity_group_alias" "admin-group-alias" {
  name           = "admin"
  mount_accessor = vault_jwt_auth_backend.authentik.accessor
  canonical_id   = vault_identity_group.admin.id
}

resource "vault_policy" "admin" {
  name   = "admin"
  policy = <<EOT
  path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo", "patch"]
  }
  EOT
}