provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "picontext"
}

resource "kubernetes_manifest" "argocd_appset" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "ApplicationSet"
    "metadata" = {
      "name"      = "argocd-apps"
      "namespace" = "argocd"
    }
    "spec" = {
      "generators" = [{
        "git" = {
          "repoURL"  = "https://github.com/myanello/homelab"
          "revision" = "main"
          "directories" = [
            {
              "path" = "argocd/**"
            },
            {
              "path"    = "argocd/dev",
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
            "name"      = "in-cluster"
            "namespace" = "{{path.basename}}"
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

resource "kubernetes_manifest" "argocd_dev_appset" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "ApplicationSet"
    "metadata" = {
      "name"      = "argocd-dev-apps"
      "namespace" = "argocd"
    }
    "spec" = {
      "generators" = [{
        "git" = {
          "repoURL"  = "https://github.com/myanello/homelab"
          "revision" = "main"
          "directories" = [
            {
              "path" = "argocd/dev/**"
            }
          ]
        }
      }]
      "template" = {
        "metadata" = {
          "name"      = "{{path.basename}}-dev-app"
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
            "name"      = "in-cluster"
            "namespace" = "{{path.basename}}-dev"
          }
          "syncPolicy" = {
            "automated" = {
              "prune"    = true
              "selfHeal" = true
            }
            "syncOptions" = [
              "CreateNamespace=true"
            ]
            "managedNamespaceMetadata" = {
              "labels" : {
                "istio-injection" = "enabled"
              }
            }
          }
        }
      }
    }
  }
}
