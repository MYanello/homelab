locals {
  oidc_mappings = [
    data.authentik_property_mapping_provider_scope.openid.id,
    authentik_property_mapping_provider_scope.email.id,
    data.authentik_property_mapping_provider_scope.profile.id,
  ]
}

module "argocd" {
  source = "./modules/oauth2-app"

  name               = "Argocd"
  slug               = "argocd"
  client_id          = "0sXKD0NdGepTvQR8TMdtPq8pjAdMna2py7EXo2cI"
  authorization_flow = data.authentik_flow.default-authorization-explicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://argocd.yanello.net/api/dex/callback"
    redirect_uri_type = "authorization"
  }]
  access_token_validity = "minutes=15"
  meta_launch_url       = "https://argocd.yanello.net/auth/login"
  open_in_new_tab       = true
}

module "grafana" {
  source = "./modules/oauth2-app"

  name               = "Grafana"
  slug               = "grafana"
  client_id          = "XenA0hD75dObUCP8bEQqQMCwlnS6dE8jGfGu11po"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://grafana.yanello.net/login/generic_oauth"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = "https://grafana.yanello.net"
}

module "argo-workflows" {
  source = "./modules/oauth2-app"

  name               = "Argo Workflows"
  slug               = "argo-workflows"
  client_id          = "gEL1mMQaxBm6nzCnv7WoKSt49IhlmrhRdnJqAiAb"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "regex"
    url               = "https://workflows.yanello.net/oauth2/callback"
    redirect_uri_type = "authorization"
  }]
  refresh_token_threshold = "hours=1"
  meta_launch_url         = "https://workflows.yanello.net"
}

module "actual-budget" {
  source = "./modules/oauth2-app"

  name               = "Actual Budget"
  slug               = "actual-budget"
  client_id          = "t1Brz0E2w2bhUxjkuQdWL9BR1ECrF79LdAJCMgqy"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://actual.yanello.net/openid/callback"
    redirect_uri_type = "authorization"
  }]
  refresh_token_threshold = "hours=1"
  meta_launch_url         = "https://actual.yanello.net"
}

module "profilarr" {
  source = "./modules/oauth2-app"

  name               = "Profilarr"
  slug               = "profilarr"
  client_id          = "pnIMAORTOJ29U0UF7J41FsWnoSEGtWEZEw4u4fH7"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://profilarr.yanello.net/auth/oidc/callback"
    redirect_uri_type = "authorization"
  }]
  refresh_token_threshold = "hours=1"
  meta_launch_url         = "https://profilarr.yanello.net"
}

module "proxmox" {
  source = "./modules/oauth2-app"

  name               = "Proxmox"
  slug               = "proxmox"
  client_id          = "nxL5ahi5XRLHCPUHm40lUVMg9gwQAlqYg4MXt29U"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [
    {
      matching_mode     = "strict"
      url               = "https://proxmox.yanello.net"
      redirect_uri_type = "authorization"
    },
    {
      matching_mode     = "strict"
      url               = "https://192.168.10.77:8006"
      redirect_uri_type = "authorization"
    }
  ]
  sub_mode        = "user_email"
  meta_launch_url = "https://proxmox.yanello.net"
}

module "mealie" {
  source = "./modules/oauth2-app"

  name               = "Mealie"
  slug               = "mealie"
  client_id          = "cVppqDAfrdBc1t0RO3o2nxddLmUkF7Ib6RtDpJ5v"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://mealie.yanello.net/login"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = "https://mealie.yanello.net"
}

module "backrest" {
  source = "./modules/proxy-app"

  name               = "Backrest"
  slug               = "backrest"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.proxy_property_mappings
  external_host      = "https://backrest.yanello.net"
  internal_host      = "http://backrest.backrest.svc.cluster.local:9898"
  meta_launch_url    = "https://backrest.yanello.net"
}

module "bazarr" {
  source = "./modules/proxy-app"

  name               = "Bazarr"
  slug               = "bazarr"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.proxy_property_mappings
  external_host      = "https://bazarr.yanello.net"
  internal_host      = "http://bazarr.bazarr.svc.cluster.local:6767"
  meta_launch_url    = "https://bazarr.yanello.net"
}

module "change-detection" {
  source = "./modules/proxy-app"

  name               = "ChangeDetection"
  slug               = "change-detection"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.proxy_property_mappings
  external_host      = "https://change.yanello.net"
  internal_host      = "http://change-detection.change-detection.svc.cluster.local:5000"
  meta_launch_url    = "https://change.yanello.net"
}

module "maintainerr" {
  source = "./modules/proxy-app"

  name               = "Maintainerr"
  slug               = "maintainerr"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.proxy_property_mappings
  external_host      = "https://maintainerr.yanello.net"
  internal_host      = "http://maintainerr.maintainerr.svc.cluster.local:6246"
  meta_launch_url    = "https://maintainerr.yanello.net"
}

module "prowlarr" {
  source = "./modules/proxy-app"

  name                  = "Prowlarr"
  slug                  = "prowlarr"
  authorization_flow    = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow     = data.authentik_flow.default-invalidation-flow.id
  property_mappings     = local.proxy_property_mappings
  external_host         = "https://prowlarr.yanello.net"
  internal_host         = "http://prowlarr.prowlarr.svc.cluster.local:9696"
  meta_launch_url       = "https://prowlarr.yanello.net"
  access_token_validity = "hours=720"
}

module "qbittorrent" {
  source = "./modules/proxy-app"

  name               = "QBittorrent"
  slug               = "qb"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.proxy_property_mappings
  external_host      = "https://qbit.yanello.net"
  internal_host      = "http://qbittorrent.qbittorrent.svc.cluster.local:8080"
  meta_launch_url    = "https://qbit.yanello.net"
}

module "radarr" {
  source = "./modules/proxy-app"

  name                  = "Radarr"
  slug                  = "radarr"
  authorization_flow    = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow     = data.authentik_flow.default-invalidation-flow.id
  property_mappings     = local.proxy_property_mappings
  external_host         = "https://radarr.yanello.net"
  internal_host         = "http://radarr.radarr.svc.cluster.local:7878"
  meta_launch_url       = "https://radarr.yanello.net"
  access_token_validity = "hours=168"
}

module "shelfmark" {
  source = "./modules/proxy-app"

  name                  = "Shelfmark"
  slug                  = "shelfmark"
  authorization_flow    = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow     = data.authentik_flow.default-invalidation-flow.id
  property_mappings     = local.proxy_property_mappings
  external_host         = "https://shelfmark.yanello.net"
  internal_host         = "http://shelfmark.calibre.svc.cluster.local:8084"
  meta_launch_url       = "https://shelfmark.yanello.net"
  access_token_validity = "hours=720"
}

module "sonarr" {
  source = "./modules/proxy-app"

  name                  = "Sonarr"
  slug                  = "sonarr"
  authorization_flow    = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow     = data.authentik_flow.default-invalidation-flow.id
  property_mappings     = local.proxy_property_mappings
  external_host         = "https://sonarr.yanello.net"
  internal_host         = "http://sonarr.sonarr.svc.cluster.local:8989"
  meta_launch_url       = "https://sonarr.yanello.net"
  access_token_validity = "hours=24"
}
