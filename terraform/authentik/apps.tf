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
    url               = "https://argocd.yanello.net/api/dex/callback"
  }]
  access_token_validity = "minutes=15"
  meta_launch_url       = "https://argocd.yanello.net/auth/login"
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
    url               = "https://grafana.yanello.net/login/generic_oauth"
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
    url               = "https://workflows.yanello.net/oauth2/callback"
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
    url               = "https://actual.yanello.net/openid/callback"
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
    url               = "https://profilarr.yanello.net/auth/oidc/callback"
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
      url               = "https://proxmox.yanello.net"
    },
    {
      url               = "https://192.168.10.77:8006"
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
    url               = "https://mealie.yanello.net/login"
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

module "homecontext" {
  source = "./modules/oauth2-app"

  name               = "Homecontext"
  slug               = "homecontext"
  client_id          = "Akhdo9JGmiOd5ewTIsEqPhcYsHW9v9WmIknoTkWZ"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = concat(local.oidc_mappings, [authentik_property_mapping_provider_scope.groups.id])
  redirect_uris = [
    {
      url               = "http://localhost:8000"
    },
    {
      url               = "http://localhost:18000"
    }
  ]
  meta_launch_url = "https://homecontext.yanello.net"
}

module "airtrail" {
  source = "./modules/oauth2-app"

  name               = "Airtrail"
  slug               = "airtrail"
  client_id          = "vZRsdFAcLdaHoEl81dBwNwaizQMTisQJmgFdju4O"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://airtrail.yanello.net/login"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "hours=1"
}

module "book-orbit" {
  source = "./modules/oauth2-app"

  name               = "BookOrbit"
  slug               = "book-orbit"
  client_id          = "uwBEhZf09iZW28K0bHXgRy5iTAYIA1QqIoad2ljY"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://bookorbit.yanello.net/oauth2-callback"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "hours=1"
}

module "budgeting" {
  source = "./modules/oauth2-app"

  name               = "Budgeting"
  slug               = "budgeting"
  client_id          = "WVhi5Q9ZFd71Hk58VriK4IaBirX0Q0MjkrcUijlU"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://budgeting.yanello.net/auth/callback"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "hours=1"
}

module "calibre" {
  source = "./modules/oauth2-app"

  name               = "Calibre"
  slug               = "calibre"
  client_id          = "Qtmf7QtbvytPsgdPBeyjE6TOy8Y3oVxfsetFitiU"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://calibre.yanello.net/login/generic/authorized"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "hours=1"
}

module "core-weave-argo" {
  source = "./modules/oauth2-app"

  name               = "CoreWeave Argo"
  slug               = "core-weave-argo"
  client_id          = "aeXlzcalWLlVEjlENVR0Yt2fTEUcdlwRVUR1Cs6M"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://cw623e.cd.akuity.cloud/auth/callback"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "hours=1"
}

module "dawarich" {
  source = "./modules/oauth2-app"

  name               = "Dawarich"
  slug               = "dawarich"
  client_id          = "qqyrB6bQUtla6oDuvhSxARBlfI3PptPxuwREl69i"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://dawarich.yanello.net/users/auth/openid_connect/callback"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "hours=1"
}

module "excalidash" {
  source = "./modules/oauth2-app"

  name               = "Excalidash"
  slug               = "excalidash"
  client_id          = "ukPNSLifzkJqPAcRiha8Eqbs9fBVeERy85Wlx2y3"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://excalidash.yanello.net/api/auth/oidc/callback"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "hours=1"
}

module "forgejo" {
  source = "./modules/oauth2-app"

  name               = "Forgejo"
  slug               = "forgejo"
  client_id          = "PLW5C8ximJuuMIMrcghabHpy2pgYDCJLgp58QCxK"
  authorization_flow = data.authentik_flow.default-authorization-explicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://forgejo.yanello.net/user/oauth2/Authentik/callback"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "hours=1"
}

module "harbor" {
  source = "./modules/oauth2-app"

  name               = "Harbor"
  slug               = "harbor"
  client_id          = "h9whIBdXD7zmRwxT7AJhRcAjP7btWu6n4FTPoe8u"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://harbor.yanello.net/c/oidc/callback"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "seconds=0"
}

module "hermes" {
  source = "./modules/proxy-app"

  name               = "Hermes"
  slug               = "hermes"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.proxy_property_mappings
  external_host      = "https://hermes.yanello.net"
  internal_host      = "http://hermes-service.external-services.svc.cluster.local:9119"
  meta_launch_url = ""
}

module "homebox" {
  source = "./modules/oauth2-app"

  name               = "Homebox"
  slug               = "homebox"
  client_id          = "XASuCNgAxUqQTxmMxGsMxTDbO6QI5ve42TxksPXW"
  authorization_flow = data.authentik_flow.default-authorization-explicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://homebox.yanello.net/api/v1/users/login/oidc/callback"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "hours=1"
}

module "immich" {
  source = "./modules/oauth2-app"

  name               = "Immich"
  slug               = "immich"
  client_id          = "yjbamkr1FolpxX2Yqy9wxXPJgeW5x99FsclBL5n2"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [
    {
      matching_mode     = "strict"
      url               = "app.immich:///oauth-callback"
      redirect_uri_type = "authorization"
    },
    {
      matching_mode     = "strict"
      url               = "https://immich.yanello.net/auth/login"
      redirect_uri_type = "authorization"
    },
    {
      matching_mode     = "strict"
      url               = "https://immich.yanello.net/user-settings"
      redirect_uri_type = "authorization"
    },
  ]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "seconds=0"
}

module "linkwarden" {
  source = "./modules/oauth2-app"

  name               = "Linkwarden"
  slug               = "linkwarden"
  client_id          = "67Bx3KAAXldSRDpVihw7fpuZQ1Y3I3vEvrFK1fvR"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://linkwarden.yanello.net/api/v1/auth/callback/authentik"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "seconds=0"
}

module "lube-logger" {
  source = "./modules/oauth2-app"

  name               = "LubeLogger"
  slug               = "lube-logger"
  client_id          = "wLJpkphbhsRdqudjAawPshTjHBhQkhfchidpepFn"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [
    {
      matching_mode     = "strict"
      url               = "https://lube.yanello.net/Login/RemoteAuth"
      redirect_uri_type = "authorization"
    },
    {
      matching_mode     = "strict"
      url               = "https://lube.yanello.net/Login/RemoteAuthDebug"
      redirect_uri_type = "authorization"
    },
  ]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "seconds=0"
}

module "nextcloud" {
  source = "./modules/oauth2-app"

  name               = "Nextcloud"
  slug               = "nextcloud"
  client_id          = "uJL16WbZ2eAaUW1a6VlQpRCchCasJn6Oy6CFgF2m"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = [
    data.authentik_property_mapping_provider_scope.openid.id,
    data.authentik_property_mapping_provider_scope.profile.id,
    data.authentik_property_mapping_provider_scope.entitlements.id,
  ]
  redirect_uris = [{
    url               = "https://nextcloud.yanello.net/apps/user_oidc/code"
  }]
  sub_mode = "user_username"
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "seconds=0"
}

module "open-webui" {
  source = "./modules/oauth2-app"

  name               = "Open-WebUI"
  slug               = "open-webui"
  client_id          = "FdBbr0XV4PqgF1V3pVHY5AZDxKasjOf8VunmrB0U"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://chat.yanello.net/oauth/oidc/callback"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  access_token_validity = "hours=72"
  refresh_token_validity = "days=30"
  refresh_token_threshold = "seconds=0"
}

module "paperless" {
  source = "./modules/oauth2-app"

  name               = "Paperless"
  slug               = "paperless"
  client_id          = "kWD7XdFbYJxqv8CUrO3tmNSE1hIPS9Zto4BeKkdY"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://paperless.yanello.net/accounts/oidc/authentik/login/callback/"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "seconds=0"
}

module "rxr" {
  source = "./modules/oauth2-app"

  name               = "RXResume"
  slug               = "rxr"
  client_id          = "EUDB0t3LRxEgQjxq3ZkURVnjsnZCYy5aMSzrrepF"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.oidc_mappings
  redirect_uris = [{
    matching_mode     = "strict"
    url               = "https://resume.yanello.net/api/auth/oauth2/callback/custom"
    redirect_uri_type = "authorization"
  }]
  meta_launch_url = ""
  refresh_token_validity = "days=30"
  refresh_token_threshold = "hours=1"
}

module "shelfmark-books" {
  source = "./modules/proxy-app"

  name               = "Shelfmark-Books"
  slug               = "shelfmark-books"
  authorization_flow = data.authentik_flow.default-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  property_mappings  = local.proxy_property_mappings
  external_host      = "https://bookorbit-dl.yanello.net"
  internal_host      = "http://shelfmark.books.svc.cluster.local:8084"
  meta_launch_url = ""
}
