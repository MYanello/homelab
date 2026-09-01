data "authentik_flow" "default-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-authorization-explicit-consent" {
  slug = "default-provider-authorization-explicit-consent"
}

data "authentik_flow" "default-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}

data "authentik_property_mapping_provider_scope" "openid" {
  managed = "goauthentik.io/providers/oauth2/scope-openid"
}

resource "authentik_property_mapping_provider_scope" "email" {
  name        = "email"
  scope_name  = "email"
  description = "Email scope with email_verified=true"
  expression  = <<EOF
return {
    "email": request.user.email,
    "email_verified": True,
}
EOF
}

resource "authentik_property_mapping_provider_scope" "groups" {
  name        = "groups"
  scope_name  = "groups"
  description = "User group memberships"
  expression  = <<EOF
return {
    "groups": [group.name for group in request.user.ak_groups.all()],
}
EOF
}

data "authentik_property_mapping_provider_scope" "profile" {
  managed = "goauthentik.io/providers/oauth2/scope-profile"
}

data "authentik_property_mapping_provider_scope" "ak_proxy" {
  managed = "goauthentik.io/providers/proxy/scope-proxy"
}

data "authentik_property_mapping_provider_scope" "entitlements" {
  managed = "goauthentik.io/providers/oauth2/scope-entitlements"
}

locals {
  proxy_property_mappings = [
    data.authentik_property_mapping_provider_scope.ak_proxy.id,
    data.authentik_property_mapping_provider_scope.openid.id,
    data.authentik_property_mapping_provider_scope.profile.id,
    authentik_property_mapping_provider_scope.email.id,
    data.authentik_property_mapping_provider_scope.entitlements.id,
  ]
}
