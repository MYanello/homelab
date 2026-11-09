# module "cw-argocd" {
#   source = "./modules/oauth2-app"
# 
#   name               = "cw-argocd"
#   slug               = "cw-argocd"
#   client_id          = "86038ca993a1c47dcb3c1cb73a218a4524d5f6499d9d378b"
#   authorization_flow = data.authentik_flow.default-authorization-explicit-consent.id
#   invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
#   property_mappings  = local.oidc_mappings
#   redirect_uris = [{
#     url = "https://argocd.yanello.net/api/dex/callback"
#   }]
#   meta_launch_url = "https://argocd.yanello.net/auth/login"
# }