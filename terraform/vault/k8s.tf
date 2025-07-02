resource "vault_auth_backend" "kubernetes" {
  type        = "kubernetes"
  path        = "kubernetes"
  description = "Kubernetes Auth Backend"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = "https://kubernetes.default.svc.cluster.local"
}

resource "vault_mount" "k8s_kv" {
  path        = "k8s"
  type        = "kv"
  description = "K8s Key-Value Secrets Engine"
  options = {
    version = "2"
    type    = "kv-v2"
  }
}

resource "vault_policy" "esops" {
  name   = "esops"
  policy = <<EOT
  path "k8s/esops/*" {
    capabilities = ["read", "list", "update", "delete", "create"]
  }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "esops" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "esops"
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["esops"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.esops.name]
}
