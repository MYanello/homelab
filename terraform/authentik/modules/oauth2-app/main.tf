resource "authentik_provider_oauth2" "this" {
  name                    = "Provider for ${var.name}"
  client_id               = var.client_id
  authorization_flow      = var.authorization_flow
  invalidation_flow       = var.invalidation_flow
  property_mappings       = var.property_mappings
  allowed_redirect_uris   = var.redirect_uris
  grant_types             = var.grant_types
  access_code_validity    = var.access_code_validity
  access_token_validity   = var.access_token_validity
  refresh_token_validity  = var.refresh_token_validity
  refresh_token_threshold = var.refresh_token_threshold
  issuer_mode             = "per_provider"
  sub_mode                = var.sub_mode
  signing_key             = var.signing_key
}

resource "authentik_application" "this" {
  name               = var.name
  slug               = var.slug
  protocol_provider  = authentik_provider_oauth2.this.id
  meta_launch_url    = var.meta_launch_url
  open_in_new_tab    = var.open_in_new_tab
  policy_engine_mode = "any"
}

output "provider_id" {
  value = authentik_provider_oauth2.this.id
}

output "application_id" {
  value = authentik_application.this.id
}
