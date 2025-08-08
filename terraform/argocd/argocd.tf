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
#     key                         = "argocd"
#     region                      = "homelab"
#     skip_credentials_validation = true # Skip AWS related checks and validations
#     skip_requesting_account_id  = true
#     skip_metadata_api_check     = true
#     skip_region_validation      = true
#     use_path_style              = true # Enable path-style S3 URLs, required for minio (https://<HOST>/<BUCKET> https://developer.hashicorp.com/terraform/language/settings/backends/s3#use_path_style
#   }
# }

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
          "ignoreDifferences" = [
            {
              "group" = "admissionregistration.k8s.io"
              "kind"  = "MutatingWebhookConfiguration"
              "name"  = "vault-agent-injector-cfg"
              "jqPathExpressions" = [
                ".webhooks[].clientConfig.caBundle"
              ]
            }
          ]
          "syncPolicy" = {
            "automated" = {
              "prune"    = true
              "selfHeal" = true
            }
            "syncOptions" = [
              "CreateNamespace=true",
              "ServerSideApply=false"
            ]
            "managedNamespaceMetadata" = {
              "labels" : {
                "istio-injection" = "disabled"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "argocd_talos_appset" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "ApplicationSet"
    "metadata" = {
      "name"      = "argocd-talos-apps"
      "namespace" = "argocd"
    }
    "spec" = {
      "generators" = [{
        "git" = {
          "repoURL"  = "https://github.com/myanello/homelab"
          "revision" = "main"
          "directories" = [
            {
              "path" = "talos/**"
            }
          ]
        }
      }]
      "template" = {
        "metadata" = {
          "name"      = "{{path.basename}}-talos-app"
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
            "name"      = "talos"
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
            "managedNamespaceMetadata" = {
              "labels" : {
                "istio-injection" = "disabled"
              }
            }
          }
        }
      }
    }
  }
}
