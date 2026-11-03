resource "authentik_provider_ldap" "opnsense" {
  name        = "OPNsense"
  base_dn     = "OU=opnsense,DC=ldap,DC=goauthentik,DC=io"
  bind_flow   = data.authentik_flow.default-authentication.id
  unbind_flow = data.authentik_flow.default-invalidation-flow.id
  bind_mode   = "direct"
  search_mode = "direct"

  tls_server_name = "ldap.yanello.net"
}

resource "authentik_application" "opnsense" {
  name              = "OPNsense"
  slug              = "opnsense"
  protocol_provider = authentik_provider_ldap.opnsense.id
  meta_launch_url   = "https://opn.yanello.net"
}

resource "authentik_outpost" "ldap" {
  name = "LDAP Outpost"
  type = "ldap"

  protocol_providers = [
    authentik_provider_ldap.opnsense.id,
  ]

  config = jsonencode({
    authentik_host          = "https://authentik.yanello.net"
    authentik_host_insecure = false
    log_level               = "info"
  })
}
