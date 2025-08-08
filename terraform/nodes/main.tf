provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "homecontext"
}

# terraform {
#   backend "s3" {
#     bucket = "terraform"
#     endpoints = {
#       s3 = "https://minio.yanello.net"
#     }
#     key                         = "nodes"
#     region                      = "homelab"
#     skip_credentials_validation = true # Skip AWS related checks and validations
#     skip_requesting_account_id  = true
#     skip_metadata_api_check     = true
#     skip_region_validation      = true
#     use_path_style              = true # Enable path-style S3 URLs, required for minio (https://<HOST>/<BUCKET> https://developer.hashicorp.com/terraform/language/settings/backends/s3#use_path_style
#   }
# }

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

resource "kubernetes_labels" "server" {
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = "marcus-server"
  }
  labels = {
    "accelerator"      = "coral-tpu"
    "storage.type/ssd" = "true"
    "storage.type/hdd" = "true"
    "storage.kubernetes.io/performance" : "fast"
    "cpu.performance" : "high"
    "gpu.type" : "nvidia"
  }
}

resource "kubernetes_labels" "hp-worker" {
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = "hp-worker"
  }
  labels = {
    "storage.type/ssd" = "true"
    "storage.type/hdd" = "false"
    "storage.kubernetes.io/performance" : "fast"
    "cpu.performance" : "low"
  }
}

# resource "kubernetes_labels" "office-desktop" {
#   api_version = "v1"
#   kind        = "Node"
#   metadata {
#     name = "office-desktop"
#   }
#   labels = {
#     "storage.type/ssd" = "true"
#     "storage.type/hdd" = "true"
#     "storage.kubernetes.io/performance" : "fast"
#     "cpu.performance" : "medium"
#     "gpu.type" : "amd"
#   }
# }
# resource "kubernetes_labels" "picluster0" {
#   api_version = "v1"
#   kind        = "Node"
#   metadata {
#     name = "picluster0"
#   }
#   labels = {
#     "storage.type/ssd" = "false",
#     "storage.kubernetes.io/performance" : "slow",
#     "cpu.performance" : "low"
#   }
# }

# resource "kubernetes_labels" "picluster1" {
#   api_version = "v1"
#   kind        = "Node"
#   metadata {
#     name = "picluster1"
#   }
#   labels = {
#     "storage.type/ssd" = "false",
#     "storage.kubernetes.io/performance" : "slow",
#     "cpu.performance" : "low"
#   }
# }

# resource "kubernetes_labels" "picluster2" {
#   api_version = "v1"
#   kind        = "Node"
#   metadata {
#     name = "picluster2"
#   }
#   labels = {
#     "storage.type/ssd" = "false",
#     "storage.kubernetes.io/performance" : "slow"
#     "cpu.performance" : "low"
#   }
# }

# resource "kubernetes_node_taint" "picluster0" {
#   metadata {
#     name = "picluster0"
#   }
#   taint {
#     key    = "node-role.kubernetes.io/control-plane" # Your taint key
#     value  = "true"                           # Your taint value
#     effect = "NoSchedule"                     # NoSchedule, PreferNoSchedule, or NoExecute
#   }
# }

# resource "kubernetes_node_taint" "picluster1" {
#   metadata {
#     name = "picluster1"
#   }
#   taint {
#     key    = "node-role.kubernetes.io/control-plane" # Your taint key
#     value  = "true"                           # Your taint value
#     effect = "NoSchedule"                     # NoSchedule, PreferNoSchedule, or NoExecute
#   }
# }

# resource "kubernetes_node_taint" "picluster2" {
#   metadata {
#     name = "picluster2"
#   }
#   taint {
#     key    = "node-role.kubernetes.io/control-plane" # Your taint key
#     value  = "true"                           # Your taint value
#     effect = "NoSchedule"                     # NoSchedule, PreferNoSchedule, or NoExecute
#   }
# }


resource "kubernetes_node_taint" "pc3" {
  metadata {
    name = "pc3"
  }
  taint {
    key    = "node-role.kubernetes.io/control-plane" # Your taint key
    value  = "true"                                  # Your taint value
    effect = "NoSchedule"                            # NoSchedule, PreferNoSchedule, or NoExecute
  }
}

resource "kubernetes_labels" "pc3" {
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = "pc3"
  }
  labels = {
    "storage.type/ssd" = "true",
    "storage.kubernetes.io/performance" : "fast",
    "cpu.performance" : "medium"
  }
}


resource "kubernetes_node_taint" "pc4" {
  metadata {
    name = "pc4"
  }
  taint {
    key    = "node-role.kubernetes.io/control-plane" # Your taint key
    value  = "true"                                  # Your taint value
    effect = "NoSchedule"                            # NoSchedule, PreferNoSchedule, or NoExecute
  }
}

resource "kubernetes_labels" "pc4" {
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = "pc4"
  }
  labels = {
    "storage.type/ssd" = "true",
    "storage.kubernetes.io/performance" : "fast",
    "cpu.performance" : "medium"
  }
}

resource "kubernetes_node_taint" "pc5" {
  metadata {
    name = "pc5"
  }
  taint {
    key    = "node-role.kubernetes.io/control-plane" # Your taint key
    value  = "true"                                  # Your taint value
    effect = "NoSchedule"                            # NoSchedule, PreferNoSchedule, or NoExecute
  }
}

resource "kubernetes_labels" "pc5" {
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = "pc5"
  }
  labels = {
    "storage.type/ssd" = "true",
    "storage.kubernetes.io/performance" : "fast",
    "cpu.performance" : "medium"
  }
}
