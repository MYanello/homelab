resource "vault_policy" "prometheus_scrape" {
  name   = "prometheus-scrape"
  policy = <<-EOT
    path "sys/metrics" {
      capabilities = ["read", "list"]
    }
  EOT
}

resource "vault_token" "prometheus_scrape" {
  policies     = [vault_policy.prometheus_scrape.name]
  no_parent    = true
  period       = "768h"
  display_name = "prometheus-scrape"
}

resource "kubernetes_secret_v1" "vault_metrics_token" {
  metadata {
    name      = "vault-metrics-token"
    namespace = "monitoring"
  }

  data = {
    token = vault_token.prometheus_scrape.client_token
  }
}
