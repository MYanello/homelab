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
    path "rustfs/encrypt/rustfs-default-key" { capabilities = ["update"] }
    path "rustfs/decrypt/rustfs-default-key" { capabilities = ["update"] }
    path "rustfs/keys/"                      { capabilities = ["read"] }
    path "rustfs/keys/rustfs-internal-kms-probe"            { capabilities = ["create", "read", "update"] }
    path "rustfs/generateDataKey/rustfs-internal-kms-probe" { capabilities = ["update"] }
    path "rustfs/decrypt/rustfs-internal-kms-probe"         { capabilities = ["update"] }

    path "secret/*"     { capabilities = ["create", "read", "update", "delete"] }
    path "secret/metadata/rustfs/kms/transit-metadata/*" { capabilities = ["create", "read", "update", "delete", "list"] }
  EOT
}

resource "vault_token_auth_backend_role" "rustfs_kms" {
  role_name      = "rustfs-kms"
  token_policies = [vault_policy.rustfs_kms.name]
  token_ttl      = "0"
  token_max_ttl  = "0"
  token_num_uses = 0
  orphan         = true
}

output "rustfs_kms_issue_command" {
  description = "Issue a token for rustfs from the role, then paste it into the rustfs KMS config"
  value       = "vault write -field=token auth/token/create role=rustfs-kms"
}
