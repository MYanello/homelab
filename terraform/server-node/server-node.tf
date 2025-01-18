provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "picontext"
}

resource "kubernetes_node_taint" "no_schedule" {
  metadata {
    name = "marcus-server"
  }

  taint {
    key    = "node-role.kubernetes.io/server" # Your taint key
    value  = "true"                           # Your taint value
    effect = "NoSchedule"                     # NoSchedule, PreferNoSchedule, or NoExecute
  }
}
