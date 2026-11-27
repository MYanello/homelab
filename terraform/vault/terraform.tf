resource "vault_mount" "terraform" {
  path        = "terraform"
  type        = "kv"
  description = "Terraform KV Secrets Engine"

  options = {
    version = "2"
    type    = "kv-v2"
  }
}

resource "vault_policy" "terraform" {
  name = "terraform"

  policy = <<-POL
    path "${vault_mount.terraform.path}/data/*" {
      capabilities = ["read"]
    }

    path "${vault_mount.terraform.path}/metadata/*" {
      capabilities = ["read", "list"]
    }

    path "auth/token/lookup-self" {
      capabilities = ["read"]
    }

    path "auth/token/renew-self" {
      capabilities = ["update"]
    }
  POL
}

resource "authentik_group" "terraform_appliers" {
  name = "terraform-applier"
  users = [
    data.authentik_user.marcus.id
  ]
}

resource "vault_jwt_auth_backend_role" "terraform_applier" {
  backend      = vault_jwt_auth_backend.authentik.path
  role_name    = "terraform-applier"
  role_type    = "oidc"
  user_claim   = "sub"
  groups_claim = "groups"
  oidc_scopes  = ["openid", "profile", "email", "groups"]

  bound_claims = {
    groups = authentik_group.terraform_appliers.name
  }

  allowed_redirect_uris = [
    "https://vault.yanello.net/oidc/callback",
    "https://vault.yanello.net/ui/vault/auth/authentik/oidc/callback",
    "http://localhost:8250/oidc/callback",
  ]

  token_policies          = [vault_policy.terraform.name]
  token_no_default_policy = true
}
