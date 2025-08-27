module.exports = {
  extends: [
    "config:best-practices",
    "mergeConfidence:all-badges",
    "default:automergeDigest",
  ],
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
  ignorePaths: ["argocd/dev/"],
};
