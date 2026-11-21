resource "vault_mount" "transit" {
  path = "rustfs"
  type = "transit"
}

resource "vault_mount" "kv" {
  path = "secret"
  type = "kv"
  options = {
    version = "2",
    type    = "kv-v2"
  }
}

resource "vault_transit_secret_backend_key" "rustfs" {
  name       = "rustfs-default-key"
  backend    = vault_mount.transit.path
  type       = "aes256-gcm96"
  exportable = false
}

resource "vault_policy" "rustfs_kms" {
  name   = "rustfs-kms"
  policy = <<-EOT
    path "rustfs/keys"          { capabilities = ["list"] }
    path "rustfs/keys/*"        { capabilities = ["create", "read", "update", "delete", "list"] }
    path "rustfs/keys/*/config" { capabilities = ["read", "update"] }
    path "rustfs/keys/*/rotate" { capabilities = ["update"] }
    path "rustfs/encrypt/*"     { capabilities = ["create", "update"] }
    path "rustfs/decrypt/*"     { capabilities = ["create", "update"] }
    path "rustfs/rewrap/*"      { capabilities = ["create", "update"] }

    path "secret/data/rustfs/kms/transit-metadata/*"     { capabilities = ["create", "read", "update"] }
    path "secret/metadata/rustfs/kms/transit-metadata/*" { capabilities = ["read", "list", "delete"] }

    path "auth/token/lookup-self" { capabilities = ["read"] }
    path "auth/token/renew-self"  { capabilities = ["update"] }
  EOT
}

resource "vault_auth_backend" "approle" {
  type        = "approle"
  path        = "approle"
}

resource "vault_approle_auth_backend_role" "rustfs_kms" {
  backend                 = vault_auth_backend.approle.path
  role_name               = "rustfs-kms"
  token_policies          = [vault_policy.rustfs_kms.name]
  token_ttl               = 3600 # RustFS per-attempt timeout (default 30s)
  token_max_ttl           = 86400
  token_no_default_policy = true
  token_num_uses          = 0
  secret_id_ttl           = 0
  secret_id_num_uses      = 0
}
