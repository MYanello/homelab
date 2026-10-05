provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "homecontext"
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
          "ignoreDifferences" = [
            {
              "group" = "apps"
              "kind" = "StatefulSet"
              "jqPathExpressions" = [
                ".spec.volumeClaimTemplates[].apiVersion",
                ".spec.volumeClaimTemplates[].kind"
              ]
            },
            {
              "group" = "admissionregistration.k8s.io"
              "kind"  = "MutatingWebhookConfiguration"
              "name"  = "vault-agent-injector-cfg"
              "jqPathExpressions" = [
                ".webhooks[].clientConfig.caBundle"
              ]
            },
            {
              "group" = "gateway.networking.k8s.io"
              "kind"  = "HTTPRoute"
              "jqPathExpressions" = [
                ".status",
                ".spec.parentRefs[].group",
                ".spec.parentRefs[].kind",
                ".spec.rules[].backendRefs[].group",
                ".spec.rules[].backendRefs[].kind",
                ".spec.rules[].backendRefs[].weight",
                ".spec.rules[].matches"
              ]
            },
            {
              "group" = "gateway.networking.k8s.io"
              "kind"  = "TCPRoute"
              "jqPathExpressions" = [
                ".status",
                ".spec.parentRefs[].group",
                ".spec.parentRefs[].kind",
                ".spec.rules[].backendRefs[].group",
                ".spec.rules[].backendRefs[].kind",
                ".spec.rules[].backendRefs[].weight"
              ]
            },
            {
              "group" = "gateway.networking.k8s.io"
              "kind"  = "TLSRoute"
              "jqPathExpressions" = [
                ".status",
                ".spec.parentRefs[].group",
                ".spec.parentRefs[].kind",
                ".spec.rules[].backendRefs[].group",
                ".spec.rules[].backendRefs[].kind",
                ".spec.rules[].backendRefs[].weight"
              ]
            },
            {
              "group" = "gateway.networking.k8s.io"
              "kind"  = "GRPCRoute"
              "jqPathExpressions" = [
                ".status",
                ".spec.parentRefs[].group",
                ".spec.parentRefs[].kind",
                ".spec.rules[].backendRefs[].group",
                ".spec.rules[].backendRefs[].kind",
                ".spec.rules[].backendRefs[].weight"
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
              "ServerSideApply=true"
            ]
          }
        }
      }
    }
  }
}

# resource "kubernetes_manifest" "argocd_talos_appset" {
#   manifest = {
#     "apiVersion" = "argoproj.io/v1alpha1"
#     "kind"       = "ApplicationSet"
#     "metadata" = {
#       "name"      = "argocd-talos-apps"
#       "namespace" = "argocd"
#     }
#     "spec" = {
#       "generators" = [{
#         "git" = {
#           "repoURL"  = "https://github.com/myanello/homelab"
#           "revision" = "main"
#           "directories" = [
#             {
#               "path" = "talos/**"
#             }
#           ]
#         }
#       }]
#       "template" = {
#         "metadata" = {
#           "name"      = "{{path.basename}}-talos-app"
#           "namespace" = "argocd"
#         }
#         "spec" = {
#           "project" = "default"
#           "source" = {
#             "repoURL"        = "https://github.com/myanello/homelab"
#             "targetRevision" = "main"
#             "path"           = "{{path}}"
#           }
#           "destination" = {
#             "name"      = "talos"
#             "namespace" = "{{path.basename}}"
#           }
#           "syncPolicy" = {
#             "automated" = {
#               "prune"    = true
#               "selfHeal" = true
#             }
#             "syncOptions" = [
#               "CreateNamespace=true"
#             ]
#           }
#         }
#       }
#     }
#   }
# }

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
          }
        }
      }
    }
  }
}
