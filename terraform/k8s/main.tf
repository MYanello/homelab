provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "homecontext"
}

terraform {
  backend "s3" {
    profile = "backblaze"
    bucket  = "myanello-tf"
    key     = "terraform/k8s.tfstate"
    endpoints = {
      s3 = "https://s3.us-west-004.backblazeb2.com"
    }
    region                      = "us-west-004"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
}

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
  }
}

resource "kubernetes_node_taint" "pc3" {
  metadata {
    name = "pc3"
  }
  taint {
    key    = "node-role.kubernetes.io/control-plane"
    value  = "true"
    effect = "NoSchedule"
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
    key    = "node-role.kubernetes.io/control-plane"
    value  = "true"
    effect = "NoSchedule"
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
    key    = "node-role.kubernetes.io/control-plane"
    value  = "true"
    effect = "NoSchedule"
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

resource "kubernetes_labels" "ubuntu-k3s" {
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = "ubuntu-k3s"
  }
  labels = {
    "storage.type/ssd" = "true",
    "storage.kubernetes.io/performance" : "fast",
    "cpu.performance" : "fast"
  }
}