provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "picontext"
}

# resource "kubernetes_node_taint" "no_schedule" {
#   metadata {
#     name = "marcus-server"
#   }
#   taint {
#     key    = "nvidia.com/gpu" # Your taint key
#     value  = "true"                           # Your taint value
#     effect = "NoSchedule"                     # NoSchedule, PreferNoSchedule, or NoExecute
#   }
# }

# resource "kubernetes_labels" "server" {
#   api_version = "v1"
#   kind        = "Node"
#   metadata {
#     name = "marcus-server"
#   }
#   labels = {
#     "nvidia.com/gpu.present" = "true",
#     "accelerator" = "coral-tpu",
#     "storage.type/ssd" = "true",
#     "storage.type/hdd" = "true",
#     "storage.kubernetes.io/performance": "fast"
#     "cpu.performance": "high"

#  }
# }

resource "kubernetes_labels" "hp-worker" {
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = "hp-worker"
  }
  labels = {
    "storage.type/ssd" = "true",
    "storage.kubernetes.io/performance" : "fast",
    "cpu.performance" : "low"
  }
}

resource "kubernetes_labels" "picluster0" {
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = "picluster0"
  }
  labels = {
    "storage.type/ssd" = "false",
    "storage.kubernetes.io/performance" : "slow",
    "cpu.performance" : "medium"
  }
}

resource "kubernetes_labels" "picluster1" {
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = "picluster1"
  }
  labels = {
    "storage.type/ssd" = "false",
    "storage.kubernetes.io/performance" : "slow",
    "cpu.performance" : "medium"
  }
}

resource "kubernetes_labels" "picluster2" {
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = "picluster2"
  }
  labels = {
    "storage.type/ssd" = "false",
    "storage.kubernetes.io/performance" : "slow"
    "cpu.performance" : "medium"
  }
}
