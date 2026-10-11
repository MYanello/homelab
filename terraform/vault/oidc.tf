locals {
  oidc_mappings = [
    data.authentik_property_mapping_provider_scope.openid.id,
    data.authentik_property_mapping_provider_scope.email.id,
    data.authentik_property_mapping_provider_scope.profile.id,
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
data "authentik_flow" "default-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}
data "authentik_flow" "default-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
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
    url               = "https://vault.yanello.net/oauth/oidc/callback"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
}
