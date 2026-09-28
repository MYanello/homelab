module.exports = {
  extends: [
    "config:best-practices",
    "mergeConfidence:all-badges",
    "default:automergeDigest",
  ],
  minimumReleaseAge: "3 days",
  digest: {
    automerge: true,
  },
  ignoreTests: true,
  prBodyColumns: ["Package", "Update", "Change", "Package file"],
  rebaseWhen: "behind-base-branch",
  dependencyDashboard: true,
  major: {
    dependencyDashboardApproval: true,
  },
  minor: {
    automerge: true,
    dependencyDashboardApproval: false,
  },
  patch: {
    automerge: true,
    dependencyDashboardApproval: false,
  },
  dependencyDashboardOSVVulnerabilitySummary: "all",
  osvVulnerabilityAlerts: true,
  vulnerabilityAlerts: {
    enabled: true,
    vulnerabilityFixStrategy: "lowest",
  },
  argocd: {
    managerFilePatterns: ["argocd/**/*.yaml$", "talos/**/*.yaml$"],
  },
  kubernetes: {
    managerFilePatterns: ["argocd/**/*.yaml", "talos/**/*.yaml"],
  },
  packageRules: [
    {
      matchManagers: ["kustomize"],
      matchUpdateTypes: ["pinDigest"],
      enabled: false,
    },
    {
      matchDatasources: ["docker"],
      allowedVersions: "/^v?[0-9]+\\.[0-9]+/",
    },
    {
      matchDepNames: ["harbor.yanello.net/ghcr/hotio/prowlarr"],
      versioning: "regex:^release-(?<major>\\d+)\\.(?<minor>\\d+)\\.(?<patch>\\d+)\\.(?<build>\\d+)$",
      allowedVersions: "/^release-[0-9]+\\.[0-9]+/",
    },
  ],
  ignorePaths: ["argocd/dev/**"],
  registryAliases: {
    "harbor.yanello.net/docker": "registry-1.docker.io",
    "harbor.yanello.net/ghcr": "harbor.yanello.net/ghcr",
    "harbor.yanello.net/quay": "quay.io",
    "harbor.yanello.net/lscr": "lscr.io",
  },
  lockFileMaintenance: {
    enabled: true,
    automerge: true,
  },
  branchConcurrentLimit: 50,
  prConcurrentLimit: 50,
  prHourlyLimit: 0,
  hostRules: [
    {
      matchHost: "harbor.yanello.net",
      allowInternal: true,
    },
  ],
};
