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
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
  EOT
}

resource "vault_mount" "kv" {
  path        = "secret"
  type        = "kv"
  description = "Key-Value Secrets Engine"
  options = {
    version = "2"
    type    = "kv-v2"
  }
}

resource "vault_auth_backend" "kubernetes" {
  type        = "kubernetes"
  path        = "kubernetes"
  description = "Kubernetes Auth Backend"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = "https://$KUBERNETES_PORT_443_TCP_ADDR:443"
}


### ESOps Setup
resource "vault_mount" "k8s_kv" {
  path        = "k8s"
  type        = "kv"
  description = "K8s Key-Value Secrets Engine"
  options = {
    version = "2"
    type    = "kv-v2"
  }
}

resource "vault_policy" "esops" {
  name   = "esops"
  policy = <<EOT
  path "k8s/*" {
    capabilities = ["read", "list", "update", "delete", "create"]
  }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "esops" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "esops"
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["esops"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.esops.name]
}


# resource "vault_policy" "internal-db-reader" {
#   name   = "internal-db-reader"
#   policy = <<EOT
#   path "/secret/database/config" {
#   capabilities = ["read"]
#   }
#   EOT
# }

# resource "vault_kubernetes_auth_backend_role" "internal-db" {
#   backend                          = vault_auth_backend.kubernetes.path
#   role_name                        = "example-role"
#   bound_service_account_names      = ["internal-app"]
#   bound_service_account_namespaces = ["default"]
#   token_ttl                        = "3600"
#   token_policies                   = [vault_policy.internal-db-reader.name]
# }
