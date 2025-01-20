provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "picontext"
}

resource "kubernetes_node_taint" "gpu" {
  metadata {
    name = "marcus-server"
  }
  taint {
    key    = "nvidia.com/gpu" # Your taint key
    value  = "true"                           # Your taint value
    effect = "NoSchedule"                     # NoSchedule, PreferNoSchedule, or NoExecute
  }
}