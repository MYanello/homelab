provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "picontext"
}

resource "kubernetes_manifest" "argocd_appset" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "ApplicationSet"
    "metadata" = {
      "name" = "argocd-apps"
      "namespace" = "argocd"
    }
    "spec" = {
      "generators" = [{
        "git" = {
          "repoURL"   = "https://github.com/myanello/homelab"
          "revision"  = "main"
          "directories" = [
            {
              "path" = "argocd/apps/**"
            },
            {
              "path" = "argocd/apps/kubeshark"
              "exclude" = true
            }
          ]
        }
      }]
      "template" = {
        "metadata" = {
          "name"      = "{{path.basename}}-app"
          "namespace" = "argocd"
        }
        "spec" = {
          "project" = "default"
          "source" = {
            "repoURL"        = "https://github.com/myanello/homelab"
            "targetRevision" = "main"
            "path"           = "{{path}}"
          }
          "destination" = {
            "name" = "in-cluster"
          }
          "syncPolicy" = {
            "automated" = {
              "prune"    = true
              "selfHeal" = true
            }
            "syncOptions" = [
              "CreateNamespace=true"
            ]
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "argocd_cm" {
  manifest = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "argocd-cm"
      namespace = "argocd"
      labels = {
        "app.kubernetes.io/part-of" = "argocd"
      }
    }
    data = {
      "kustomize.buildOptions" = "--enable-helm --enable-alpha-plugins --enable-exec"
    }
  }
}

resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "argocd.yanello.net"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
}
