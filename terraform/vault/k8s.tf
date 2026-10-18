resource "kubernetes_secret_v1" "vault_reviewer_token" {
  metadata {
    name      = "vault-token-reviewer"
    namespace = "vault"
    annotations = {
      "kubernetes.io/service-account.name" = "vault-token-reviewer"
    }
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

data "kubernetes_config_map_v1" "root_ca" {
  metadata {
    name      = "kube-root-ca.crt"
    namespace = "vault"
  }
}

resource "vault_auth_backend" "kubernetes" {
  type        = "kubernetes"
  path        = "kubernetes"
  description = "Kubernetes Auth Backend"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = "https://192.168.10.100:6443"
  kubernetes_ca_cert = data.kubernetes_config_map_v1.root_ca.data["ca.crt"]
  token_reviewer_jwt = kubernetes_secret_v1.vault_reviewer_token.data["token"]
  issuer             = "https://k8s.yanello.net"
}

resource "vault_mount" "k8s_kv" {
  path        = "k8s-kv"
  type        = "kv"
  description = "Kubernetes KV Secrets Engine"
  options = {
    version = "2"
    type    = "kv-v2"
  }
}

resource "vault_policy" "esops" {
  name   = "esops"
  policy = <<-POL
    path "${vault_mount.k8s_kv.path}/data/*" {
      capabilities = ["create", "read", "update", "patch", "delete"]
    }
    path "${vault_mount.k8s_kv.path}/metadata/*" {
      capabilities = ["read", "list", "delete"]
    }
    path "${vault_mount.pki.path}/cert/ca" {
      capabilities = ["read"]
    }
    path "${vault_mount.pki_int.path}/cert/ca" {
      capabilities = ["read"]
    }
  POL
}

resource "vault_kubernetes_auth_backend_role" "esops" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "esops"
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["external-secrets"]
  token_ttl                        = 3600
  token_max_ttl                    = 86400
  token_policies                   = [vault_policy.esops.name]
}
