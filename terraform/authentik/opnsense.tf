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
  name               = "OPNsense"
  slug               = "opnsense"
  protocol_provider  = authentik_provider_ldap.opnsense.id
  meta_launch_url    = "https://opn.yanello.net"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "opnsense-admin" {
  target = authentik_provider_ldap.opnsense.id
  group  = data.authentik_group.admin.id
  order  = 0
}

data "sops_file" "authentik" {
  source_file = "sops/authentik.enc.yaml"
  input_type  = "yaml"
}

resource "authentik_user" "opnsense" {
  username  = "opnsense-user"
  name      = "OPNsense LDAP Bind"
  path      = "service-accounts"
  type      = "service_account"
  is_active = true
  password  = data.sops_file.authentik.data["opnsense_ldap_bind_password"]
}

resource "authentik_rbac_role" "opnsense-ldap-search" {
  name = "opnsense-ldap-search"
}

resource "authentik_rbac_permission_role" "opnsense-search" {
  role       = authentik_rbac_role.opnsense-ldap-search.id
  permission = "authentik_providers_ldap.search_full_directory"
}

resource "authentik_group" "opnsense-ldap-search" {
  name  = "opnsense-ldap-search"
  roles = [authentik_rbac_role.opnsense-ldap-search.id]
  users = [authentik_user.opnsense.id]
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
