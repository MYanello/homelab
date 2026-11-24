resource "vault_quota_rate_limit" "global_ip" {
  name           = "global-ip"
  path           = ""
  rate           = 100
  interval       = 1
  block_interval = 60
  group_by       = "ip"
}

resource "vault_quota_rate_limit" "authentik_login_ip" {
  name           = "authentik-login-ip"
  path           = "auth/authentik/"
  rate           = 5
  interval       = 1
  block_interval = 60
  group_by       = "ip"
}

resource "vault_quota_rate_limit" "cks_login_ip" {
  name           = "cks-login-ip"
  path           = "auth/cks/"
  rate           = 5
  interval       = 1
  block_interval = 60
  group_by       = "ip"
}

resource "vault_generic_endpoint" "quota_config" {
  path           = "sys/quotas/config"
  disable_read   = true
  disable_delete = true

  data_json = jsonencode({
    enable_rate_limit_audit_logging = true
  })
}
