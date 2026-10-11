locals {
  oidc_mappings = [
    data.authentik_property_mapping_provider_scope.openid.id,
    data.authentik_property_mapping_provider_scope.email.id,
    data.authentik_property_mapping_provider_scope.profile.id,
    data.authentik_property_mapping_provider_scope.groups.id
  ]
}

data "authentik_property_mapping_provider_scope" "openid" {
  managed = "goauthentik.io/providers/oauth2/scope-openid"
}
data "authentik_property_mapping_provider_scope" "email" {
  managed = "goauthentik.io/providers/oauth2/scope-email"
}
data "authentik_property_mapping_provider_scope" "profile" {
  managed = "goauthentik.io/providers/oauth2/scope-profile"
}
data "authentik_property_mapping_provider_scope" "groups" {
  name = "groups"
}
data "authentik_flow" "default-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}
data "authentik_flow" "default-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}

data "authentik_user" "marcus" {
  username = "marcus"
}

module "vault-oauth-app" {
  source = "../authentik/modules/oauth2-app"

  name               = "Vault"
  slug               = "vault"
  client_id          = "6cca685876ab9a35a6fbd9937b3d9ea09cd1"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://vault.yanello.net/ui/vault/auth/oidc/oidc/callback"
    redirect_uri_type = "authorization"
    },
    {
      matching_mode     = "strict"
      url               = "http://localhost:8250/oidc/callback"
      redirect_uri_type = "authorization"
    }
  ]
  meta_launch_url = ""
}

resource "authentik_group" "vault-admins" {
  name = "vault-admin"
  users = [
    data.authentik_user.marcus.id
  ]
}

resource "vault_jwt_auth_backend" "authentik" {
  path               = "oidc"
  type               = "oidc"
  description        = "Authentik OIDC auth backend"
  default_role       = "admin"
  oidc_discovery_url = module.vault-oauth-app.issuer_url
  oidc_client_id     = module.vault-oauth-app.client_id
  oidc_client_secret = module.vault-oauth-app.client_secret
  bound_issuer       = module.vault-oauth-app.issuer_url

  tune {
    max_lease_ttl      = "768h"
    default_lease_ttl  = "24h"
    listing_visibility = "unauth"
  }
}

resource "vault_jwt_auth_backend_role" "admin" {
  backend      = vault_jwt_auth_backend.authentik.path
  role_name    = "admin"
  role_type    = "oidc"
  user_claim   = "sub"
  groups_claim = "groups"
  oidc_scopes  = ["openid", "profile", "email", "groups"]

  allowed_redirect_uris = [
    "https://vault.yanello.net/oidc/callback",
    "https://vault.yanello.net/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
  ]
}

resource "vault_identity_group" "vault_admin" {
  name     = "vault-admin"
  type     = "external"
  policies = [vault_policy.admin.name]
}

resource "vault_identity_group_alias" "vault_admin" {
  name           = "vault-admin"
  mount_accessor = vault_jwt_auth_backend.authentik.accessor
  canonical_id   = vault_identity_group.vault_admin.id
}


resource "vault_policy" "admin" {
  name   = "admin"
  policy = <<-EOT
    path "*" {
      capabilities = ["create", "read", "update", "delete", "list", "sudo", "patch"]
    }
  EOT
}
