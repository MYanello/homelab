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
  rebaseWhen: "auto",
  dependencyDashboard: true,
  major: {
    dependencyDashboardApproval: false,
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
  packageRules: [
    {
      matchUpdateTypes: ["pin", "pinDigest"],
      minimumReleaseAge: null,
    },
    {
      // kustomize helmCharts cannot hold a digest, so pinning them produces no
      // change and fails the whole pin job
      matchManagers: ["kustomize"],
      matchUpdateTypes: ["pinDigest"],
      enabled: false,
    },
    {
      matchDatasources: ["docker"],
      allowedVersions: "/^v?[0-9]+\\.[0-9]+/",
    },
  ],
  registryAliases: {
    "harbor.yanello.net/docker": "registry-1.docker.io",
    "harbor.yanello.net/ghcr": "ghcr.io",
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
