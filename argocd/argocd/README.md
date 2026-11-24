## Bootstrap order

1. Vault VM. `ansible/vault` provisions the host, `terraform/vault` configures the Kubernetes auth mount, the `k8s-kv` mount, the `esops` policy and role. Vault unseals against OCI KMS, and the seal material in `terraform/vault/sops/` stays outside Vault by design.
2. The `external-secrets` Application, which syncs the `vault` ClusterSecretStore.
3. The `argocd` Application.
4. Everything else.
5. Argocd takes control of itself and externa-secrets after bringup

## Sops Key

The repo-server reads the age key from the `sops-age` Secret, populated from Vault at `general/SOPS_AGE_KEY`. Manual fallback when Vault is unreachable:

```
kubectl create secret generic sops-age -n argocd --from-literal=key.txt=${KEY}
```
