resource "authentik_provider_proxy" "this" {
  name                   = "Provider for ${var.name}"
  authorization_flow     = var.authorization_flow
  invalidation_flow      = var.invalidation_flow
  property_mappings      = var.property_mappings
  mode                   = "proxy"
  external_host          = var.external_host
  internal_host          = var.internal_host
  access_token_validity  = var.access_token_validity
  refresh_token_validity = "days=30"
}

resource "authentik_application" "this" {
  name               = var.name
  slug               = var.slug
  protocol_provider  = authentik_provider_proxy.this.id
  meta_launch_url    = var.meta_launch_url
  open_in_new_tab    = var.open_in_new_tab
  policy_engine_mode = "any"
}

output "provider_id" {
  value = authentik_provider_proxy.this.id
}

output "application_id" {
  value = authentik_application.this.id
}
