output "provider_id" {
  value = authentik_provider_oauth2.this.id
}

output "application_id" {
  value = authentik_application.this.id
}

output "client_id" {
  value = authentik_provider_oauth2.this.client_id
}

output "client_secret" {
  value = authentik_provider_oauth2.this.client_secret
}

output "issuer_url" {
  value = "${var.authentik_url}/application/o/${var.slug}/"
}

output "discovery_url" {
  value = "${var.authentik_url}/application/o/${var.slug}/.well-known/openid-configuration"
}
